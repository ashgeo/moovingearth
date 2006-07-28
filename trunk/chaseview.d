module chaseview;

private import readgps;
private import views;
private import gemath;
private import kmlsource;
private import std.math;

class chaseView_t : kmlSource
{
	this( char[] kml_temp )
	{
		super( kml_temp );
	}

	private kml_t info;

	bool Update()
	{
		synchronized( gpsReader )
		{
			// If gps version is the same, skippit.
			if ( info.gps.gga_time == gpsReader.gps_lastknowngood.gga_time )
				return false;

			info.gps = gpsReader.gps_lastknowngood;
		}

		// Calculate the current lat/lon meter-degree scaling (for later use)
		real lat_rad = deg2rad( info.gps.latitude );
		static real lat_deg_p_meter = 360.0 / 40_007_000.0;
		real lon_deg_p_meter = 360.0 / (40_075_000.0 * cos( lat_rad) );
		real course_rad = deg2rad( info.gps.course );

		// Choose eye altitude
		real eye_alti = 150.0 + 5.0 * info.gps.kmh;

		// next code is not OK: alti is relative to ground, where altitude is absolute
		// so works at see level land, but not in mountains
		// anyway is useful mainly for Flights, for which we'll write a different writefunc
	//	if (chaseview.gps.altitude > eye_alti)
	//		eye_alti = info.gps.altitude;

		// Set tilt
		real tilt = 60.0;

		// show position 15 degrees more 'down' than tilt angle
		// but never negative
		real pos_angle = tilt - 15.0;
		if (pos_angle<0) 
			pos_angle = 0;

		// Calculate the position in the center of the view, so that
		//  the position will show up on the right place in the bottom of the view
		real hor_distance_t = tan( deg2rad( tilt ) ) * eye_alti;
		real hor_distance_a = tan( deg2rad( pos_angle ) ) * eye_alti;
		// look so far ahead:
		real correction = hor_distance_t - hor_distance_a;
		// and that is so many degrees of lat/lon
		info.view.latitude = info.gps.latitude + cos( course_rad ) * lat_deg_p_meter * correction;
		info.view.longitude = info.gps.longitude + sin( course_rad ) * lon_deg_p_meter * correction;

		// Fill the other view stuff
		info.view.tilt = tilt;
		info.view.direction = info.gps.course;

		// Calc the range so that the eye altitude is as desired
		info.view.range = eye_alti / cos( deg2rad( tilt ) );

		// make the kml data
		kml = fillTemplate( kml_template, info );

		return true;
	}
}

