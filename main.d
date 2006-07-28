private import std.stdio;
private import std.string;
private import std.file,std.c.time;

// imports for comms, ini, webserver
private import comm, httpd, ini_win32;

private import nmeahub;
private ComPortGPS gps;

private void init()
{
	gps = new ComPortGPS;
	scope(failure) delete gps;

	int triesleft = 5;
	while (1) {
		try {
			gps.open( Settings.comPort, cast (uint) Settings.baudRate.atoi() );
		}
		catch ( Object o )
		{
			if (--triesleft == 0)
				throw o;

			writefln( "Open failed, trying again..." );
			msleep( 500 );
			continue;
		}
		break;
	}
}

private void deinit()
{
	delete gps;
}

private void run()
{
	auto ListenThread listener = new ListenThread;
	listener.ip = Settings.listenIP;
	listener.port = cast(ushort) Settings.listenPort.atoi();
	listener.start();

	while (!kbhit() && listener.getState != std.thread.Thread.TS.TERMINATED)
	{
		ubyte buffer[512];
		uint read = gps.read( buffer );

		// If no data was received, probably the com port was broken (disconnected)
		if (read == 0)
			break;

		nmeaHub.onNMEA( buffer[0..read] );
	}
	listener.stop();
	writefln( "Waiting for webserver to stop" );
	listener.wait();
}

int main()
{
	try {
		init();
		scope(exit) deinit();

		run();
	}
	catch ( Object o )
	{
		writefln( "The following error occurred:" );
		writef( "%s", o.toString() );
		getchar();
		return 1;
	}
	return 0;
}
