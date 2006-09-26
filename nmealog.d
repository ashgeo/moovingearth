module nmealog;

private import std.stdio;

private import nmeahub;

class nmeaLogger
{
	private char[] outfile;
	this( char[] folder, char[] filen ) {
		outfile = folder ~ filen;

		// OK, ready for data
		synchronized( nmeaHub )
			nmeaHub.nmeaProcessors ~= &onNMEA;
	}

	void onNMEA( ubyte[] data ) {
		try {
			std.file.append( outfile, data );
		}
		catch
		{
			writefln( "Could not log NMEA" );
		}
	}

}
