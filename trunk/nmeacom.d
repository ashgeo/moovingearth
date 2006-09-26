module nmeacom;

private import comm;
private import nmeasource;
private import std.stdio;
private import win32.winbase;

class ComPortGPS : public NMEASource
{
	private ComPortEx comm;

	this() {
		comm = new ComPortEx;
	}

	~this() {
		delete comm;
	}

	void open( char[] dev, uint baud = 4800 ) {
		if (dev.length==0)
			throw new Exception( "No COM port" );
		comm.open( dev );

		comm.dcb.BaudRate = baud;		  // set the baud rate
		comm.dcb.ByteSize = 8;             // data size, xmit, and rcv
		comm.dcb.Parity = NOPARITY;        // no parity bit
		comm.dcb.StopBits = ONESTOPBIT;    // one stop bit
		comm.setState();

		comm.to.ReadIntervalTimeout = 100;
		comm.setTimeouts();
		writefln("Reading NMEA data from " ~ dev );
	}

	uint read( void[] buffer ) {
		return comm.read( buffer );
	}
}
