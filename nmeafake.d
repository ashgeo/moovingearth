module nmeafake;

private import nmeasource;
private import std.c.time;
private import std.stdio;

class FakeGPS : public NMEASource
{
	void open( char[] dev, uint baud = 4800 ) {
		writefln("Generating fake NMEA data");
		return;
	}

	uint read( void[] buffer ) {
		msleep(3000); // every 3 sec
		char[] inn = 
			"$GPGGA,120557.916,5058.7456,N,00647.0515,E,2,06,1.7,108.5,M,47.6,M,1.5,0000*7A\r\n"
//			"$GPGSA,A,3,20,11,25,01,14,31,,,,,,,2.6,1.7,1.9*3B\r\n"
//			"$GPGSV,2,1,08,11,74,137,45,20,58,248,43,07,27,309,00,14,23,044,36*7A\r\n"
//			"$GPGSV,2,2,08,01,14,187,41,25,13,099,39,31,11,172,37,28,09,265,*71\r\n"
			"$GPRMC,120557.916,A,5058.7456,N,00647.0515,E,0.00,82.33,220503,,*39\r\n";
		assert( buffer.length >= inn.length );
		buffer[0..inn.length] = cast (void[]) inn;
		return inn.length;
	}
}
