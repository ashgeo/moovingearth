module views;

private import readgps;
private import ini_win32;

struct view_t
{
	real		tilt = 0;
	real		range = 200;
	real		direction = 0;
	real		latitude = 0;
	real		longitude = 0;
}

struct kml_t
{
	gps_t		gps;
	view_t		view;
}

// Generic templates
char[] fillTemplate( char[] template_kml )
{
	// Make the KML
	char[] outFile = template_kml;
	outFile = std.string.replace( outFile, "$servername", Settings.serverName );
	return outFile;
}

char[] age( gps_t gps )
{
	// TODO: give the age in readable format
	// "Actual" or "Now" or "Current" (max 30 sec delay or so)
	// ".. minutes ago"
	// ".. hours ago (from 2 hours up to another day)
	// "Last  tuesday" (max 5-6 days)
	// "date" (longer ago) 
	return std.string.format( "%08d %.0f", gps.date, gps.seconds );
}

// GPS data templates
char[] fillTemplate( char[] template_kml, gps_t gps )
{
	// Make the KML
	char[] outFile = fillTemplate( template_kml );
	// DEG + Min.4 dec -> less than 6 decimbals in degree space. (so lets use 1 more = 7)
	outFile = std.string.replace( outFile, "$latitude", std.string.format( "%.7f", gps.latitude ) );
	outFile = std.string.replace( outFile, "$longitude", std.string.format( "%.7f", gps.longitude ) );
	outFile = std.string.replace( outFile, "$speed_knots", std.string.format("%.1f", gps.knots ) );
	outFile = std.string.replace( outFile, "$speed_ms", std.string.format("%.1f", gps.m_sec ) );
	outFile = std.string.replace( outFile, "$speed_kmh", std.string.format("%.1f",  gps.kmh ) );
	outFile = std.string.replace( outFile, "$speed_mph", std.string.format("%.1f", gps.mph ) );
	outFile = std.string.replace( outFile, "$heading", std.string.format("%.1f", gps.course ) );
	outFile = std.string.replace( outFile, "$altitude", std.string.format("%.1f", gps.altitude ) );

	outFile = std.string.replace( outFile, "$predlatitude", std.string.format( "%.7f", gps.history.latitude_pred ) );
	outFile = std.string.replace( outFile, "$predlongitude", std.string.format( "%.7f", gps.history.longitude_pred ) );
	outFile = std.string.replace( outFile, "$trail", gps.history.trail );

	outFile = std.string.replace( outFile, "$smarttime", age( gps ) );
	return outFile;
}

// View templates
char[] fillTemplate( char[] template_kml, kml_t kml )
{
	char[] outFile = fillTemplate( template_kml, kml.gps );
	// DEG + Min.4 dec -> less than 6 decimbals in degree space. (so lets use 1 more = 7)
	outFile = std.string.replace( outFile, "$viewlatitude", std.string.format( "%.7f", kml.view.latitude ) );
	outFile = std.string.replace( outFile, "$viewlongitude", std.string.format( "%.7f", kml.view.longitude ) );
	outFile = std.string.replace( outFile, "$viewdirection", std.string.format("%.1f", kml.view.direction ) );
	outFile = std.string.replace( outFile, "$tilt", std.string.toString( kml.view.tilt ) );
	outFile = std.string.replace( outFile, "$range", std.string.toString( kml.view.range ) );
	return outFile;
}
