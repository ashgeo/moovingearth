module kmlsource;

import readgps;
import views;

class kmlSource
{
	this( char[] kml_temp )
	{
		kml_template = kml_temp;
	}

	protected char[] kml_template;

	char[] kml;

	abstract bool Update();
}

class kmlStaticSource : kmlSource
{
	this( char[] kml_temp )
	{
		super( kml_temp );
	}

	bool Update()
	{
		if (kml)
			return false;

		kml = fillTemplate( kml_template );
		return true;
	}
}

class kmlDataSource : kmlSource
{
	this( char[] kml_temp )
	{
		super( kml_temp );
	}

	protected gps_t gps;

	bool Update()
	{
		synchronized( gpsReader )
		{
			// If gps version is the same, skippit.
			if ( gps.gga_time == gpsReader.gps_lastknowngood.gga_time )
				return false;

			gps = gpsReader.gps_lastknowngood;
		}

		kml = fillTemplate( kml_template, gps );
		return true;
	}
}

class kmlViewSource : kmlSource
{
	this( char[] kml_temp )
	{
		super( kml_temp );
	}

	protected kml_t info;

	bool Update()
	{
		synchronized( gpsReader )
		{
			// If gps version is the same, skippit.
			if ( info.gps.gga_time == gpsReader.gps_lastknowngood.gga_time )
				return false;

			info.gps = gpsReader.gps_lastknowngood;
		}

		if (!UpdateView())
			return false;

		// make the kml data
		kml = fillTemplate( kml_template, info );

		return true;
	}

	abstract bool UpdateView();
}
