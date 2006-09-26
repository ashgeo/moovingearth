module readgps;

private import nmeap;
private import nmeahub;
pragma ( lib, "3rd\\nmeap4d.lib" );

private import gemath;

private nmeap.nmeap_context_t nmea_context;
private nmeap.nmeap_gga_t nmea_gga;
private nmeap.nmeap_rmc_t nmea_rmc;

struct history_t
{
	// trail
	char[]		trail;
	real		latitude_pred = 0;
	real		longitude_pred = 0;
}

struct gps_t
{
	// data valid flag
	bool		valid = false;

	// from RMC and/or GGA
	real		latitude = 0;
	real		longitude = 0;
	real		altitude = 0;
	real		course = 0;
	real		knots = 0;

	// calculated extra info.
	real		m_sec = 0, kmh = 0, mph = 0;

	// time
	real		seconds = 0; // after midnight (NOT NMEA!!)
	uint		date = 0; // NMEA date

	// Check: gga and rmc should be of same moment for writing
	uint		gga_time = 0, rmc_time = 0;

	// history (and prediction)
	history_t	history;
}

class gpsReader_t
{
	gps_t gps_lastknowngood;
	private gps_t gps_work;

	private this()
	{
	}

	private void OnGpsChanged()
	{
		if (gps_work.gga_time != gps_work.rmc_time)
			return;

		// Fill in speeds in all units, and history.
		CompleteGPS();

		// For now, ignore invalid info
		if (!gps_work.valid)
			return;

		// copy the gps data to 
		synchronized( this )
		{
			gps_lastknowngood = gps_work;
		}
	}

	private void CompleteGPS()
	{
	//*
		if (0)
		{
			// Calculate the current lat/lon meter-degree scaling
			real lat_rad = deg2rad( gps_work.latitude );
			static real lat_deg_p_meter = 360.0 / 40_007_000.0;
			real lon_deg_p_meter = 360.0 / (40_075_000.0 * cos( lat_rad) );

			real time = gps_work.seconds;
			// Simulate a drive
			gps_work.course = ( time * 1.0 ) % 360.0; // 6 minutes to a circle
			gps_work.course = -15 + 30 * sin( time * 0.01 );

			gps_work.knots = 35.0 + 35.0 * cos( time * 0.1 );
			gps_work.knots = 70.0; // fast car
			gps_work.knots = 600.0; gps_work.altitude = 11000.0; // plane
			gps_work.m_sec = gps_work.knots * 0.514444444;

			static real dlat_m = 0;
			static real dlon_m = 0;
			real course_rad = deg2rad( gps_work.course );
			dlat_m += cos( course_rad ) * lat_deg_p_meter * gps_work.m_sec;
			dlon_m += sin( course_rad ) * lon_deg_p_meter * gps_work.m_sec;
			gps_work.latitude += dlat_m;
			gps_work.longitude += dlon_m;
		}
	//*/

		// Calculate the user-readable speeds
		gps_work.m_sec = gps_work.knots * 0.514444444;
		gps_work.kmh = gps_work.m_sec * 3.6;
		gps_work.mph = gps_work.m_sec * (3.6 / 1.609 );

		// Calculate the current lat/lon meter-degree scaling (for later use)
		real lat_rad = deg2rad( gps_work.latitude );
		static real lat_deg_p_meter = 360.0 / 40_007_000.0;
		real lon_deg_p_meter = 360.0 / (40_075_000.0 * cos( lat_rad) );
		real course_rad = deg2rad( gps_work.course );

		// predict 30 sec from now
		real pred_time = 30.0;
		real pred_dist = pred_time * gps_work.m_sec;
		if (pred_dist < 50)
			pred_dist = 50;
		gps_work.history.latitude_pred = gps_work.latitude + cos( course_rad ) * lat_deg_p_meter * pred_dist;
		gps_work.history.longitude_pred = gps_work.longitude + sin( course_rad ) * lon_deg_p_meter * pred_dist;

		// Update the trail
		char[] pos = std.string.format("%.7f,%.7f,%.1f",gps_work.longitude,gps_work.latitude,gps_work.altitude);
/*		if (gps_work.history.trail) // Don't use ~= here: we must make a copy!
			gps_work.history.trail = gps_work.history.trail ~ "," ~ pos;
		else*/
			gps_work.history.trail = pos;
	}
}

gpsReader_t gpsReader; // Single instance

static this()
{
	gpsReader = new gpsReader_t;
	initNMEAP;
}

extern (C) private void handleRmc(nmeap_context *context, void *sentence_data, void *user_data)
{
	nmeap_rmc* rmc = cast (nmeap_rmc*) sentence_data;

	// Check NMEA validity
	gpsReader.gps_work.valid = (rmc.warn == 'A');

	gpsReader.gps_work.latitude = rmc.latitude;
	gpsReader.gps_work.longitude = rmc.longitude;
	gpsReader.gps_work.course = rmc.course;
	gpsReader.gps_work.knots = rmc.speed;

	gpsReader.gps_work.seconds = decodeNMEAtime( rmc.time );
	gpsReader.gps_work.date = rmc.date;

	// Store the rmc reception time: we only use the data if rmc and gga times are the same
	gpsReader.gps_work.rmc_time = cast(uint) gpsReader.gps_work.seconds;

	gpsReader.OnGpsChanged();
}

extern (C) private void handleGga(nmeap_context *context, void *sentence_data, void *user_data)
{
	nmeap_gga* gga = cast (nmeap_gga*) sentence_data;

	// Ignore gga latitude/longtitude: we get it from Rmc with valid flag
	//  this way we never overwrite valid Rmc data with possible invalid gga
//	info.latitude = gga.latitude;
//	info.longitude = gga.longitude;
	gpsReader.gps_work.altitude = cast(uint) gga.altitude;
	real secs = decodeNMEAtime( gga.time );

	// Store the gga reception time: we only use the data if rmc and gga times are the same
	gpsReader.gps_work.gga_time = cast(uint) secs;

	gpsReader.OnGpsChanged();
}

void initNMEAP()
{
	// Init NMEAP (last because)
	int rv;
	rv = nmeap_init( &nmea_context, null );
	if (rv != 0)
		throw new Exception("NMEAP Init failed");

/*	scope(failure)
		nmeap_deInit( &nmea_context );*/

	rv = nmeap_addParser( &nmea_context, cast(ubyte*)"GPGGA", &nmeap_gpgga, &handleGga, &nmea_gga );
	if (rv != 0)
		throw new Exception("NMEAP Add GGA failed");

	rv = nmeap_addParser( &nmea_context, cast(ubyte*)"GPRMC", &nmeap_gprmc, &handleRmc, &nmea_rmc );
	if (rv != 0)
		throw new Exception("NMEAP Add RMC failed");

	void parseBuffer( ubyte[] buffer )
	{
		int read = buffer.length;
		int remaining = read;
		while (remaining > 0)
		{
			uint offset = read - remaining;
			nmeap_parseBuffer( &nmea_context, buffer.ptr + offset, &remaining );
		}
	}

	synchronized( nmeaHub )
		nmeaHub.nmeaProcessors ~= &parseBuffer;
}
