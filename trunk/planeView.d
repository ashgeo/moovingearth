module planeview;

private import readgps;
private import views;
private import gemath;
private import kmlsource;
private import std.math;

class planeView_t : kmlViewSource
{
	this( char[] kml_temp )
	{
		super( kml_temp );
	}

	real lookdir = 0;

	bool UpdateView()
	{
		// Calculate the current lat/lon meter-degree scaling (for later use)
		real lat_rad = deg2rad( info.gps.latitude );
		static real lat_deg_p_meter = 360.0 / 40_007_000.0;
		real lon_deg_p_meter = 360.0 / (40_075_000.0 * cos( lat_rad) );
		real course_rad = deg2rad( info.gps.course );

		info.view.direction = info.gps.course + lookdir;
		real lookdir_rad = deg2rad( info.view.direction );

		// Choose eye altitude
		real above_plane = 250.0;
		real eye_alti = above_plane + info.gps.altitude;

		// next code is not OK: alti is relative to ground, where altitude is absolute
		// so works at see level land, but not in mountains
		// anyway is useful mainly for Flights, for which we'll write a different writefunc
	//	if (planeview.gps.altitude > eye_alti)
	//		eye_alti = planeview.gps.altitude;

		// Set tilt
		// we don't have to see straight down; we have other views for that
		real tilt = 25.0;

		// Calculate the position in the center of the view, so that
		//  the position will show up on the right place in the bottom of the view
		real hor_distance_t = tan( deg2rad( tilt ) ) * eye_alti;
		real hor_distance_a = tan( deg2rad( tilt ) ) * above_plane;
		// look so far ahead:
		real correction = hor_distance_t - hor_distance_a;
		// and that is so many degrees of lat/lon
		info.view.latitude = info.gps.latitude + cos( lookdir_rad ) * lat_deg_p_meter * correction;
		info.view.longitude = info.gps.longitude + sin( lookdir_rad ) * lon_deg_p_meter * correction;

		// Fill the other view stuff
		info.view.tilt = tilt;

		// Calc the range so that the eye altitude is as desired
		info.view.range = eye_alti / cos( deg2rad( tilt ) );

		return true;
	}
}

