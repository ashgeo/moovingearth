private import std.stdio;
private import std.string;
private import std.file,std.c.time;

// imports for ini, webserver, nmeas
private import nmeasource, httpd, ini_win32, udpgps, nmeacom, nmeafake;

private import nmeahub;
private NMEASource gps;

private void init()
{
	try
	{
		initCOM;
		return;
	}
	catch {}
	try {
		initUDP;
		return;
	}
	catch {}
	initFAKE;
}

private void initFAKE()
{
	gps = new FakeGPS;
	gps.open("$$gen", 0 );
}

private void initCOM()
{
	gps = new ComPortGPS;
	scope(failure) delete gps;

	int triesleft = 5;
	if (Settings.comPort.length == 0)
		triesleft = 1;

	while (1) {
		try {
			gps.open( Settings.comPort, cast (uint) Settings.baudRate.atoi() );
		}
		catch ( Object o )
		{
			if (--triesleft == 0)
				throw o;

			writefln( "Open " ~ Settings.comPort ~ " failed, trying again..." );
			msleep( 500 );
			continue;
		}
		break;
	}
}

private void initUDP()
{
	if (!Settings.listenIP.length)
		throw new Exception("No UDP");

	gps = new UDPGPS;
	gps.open( Settings.listenIP, cast (ushort) Settings.listenPort.atoi() );
}

private void deinit()
{
	delete gps;
}

private void run()
{
	auto ListenThread listener;
	if (Settings.listenIP.length)
	{
		writefln("Webserver listening on TCP " ~ Settings.listenIP ~":" ~ Settings.listenPort );
		listener = new ListenThread;
		listener.ip = Settings.listenIP;
		listener.port = cast(ushort) Settings.listenPort.atoi();
		listener.start();
	}

	auto nmeaBroadcaster Broadcaster;
	if (Settings.broadcastIP.length) {
		Broadcaster = new nmeaBroadcaster( Settings.broadcastIP, cast (uint) Settings.broadcastPort.atoi() );
		writefln("Broadcasting NMEA on UDP " ~ Settings.broadcastIP ~":" ~ Settings.broadcastPort );
	}

	while (!kbhit() && (!listener || listener.getState != std.thread.Thread.TS.TERMINATED))
	{
		ubyte buffer[512];
		uint read = gps.read( buffer );

		// If no data was received, probably the com port was broken (disconnected)
		if (read == 0)
			break;

		nmeaHub.onNMEA( buffer[0..read] );
	}
	writefln("Stopping");
	if (listener)
	{
		listener.stop();
		writefln( "Waiting for webserver to stop" );
		listener.wait();
	}
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
	writefln("Gone");
	return 0;
}
