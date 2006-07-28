module kmlserver;

private import std.string, std.file, std.uri;
private import httpd;
private import std.socket;
private import std.stdio;
private import std.string;

private import chaseview, planeview;
private import readgps;
private import kmlsource;
private import ini_win32;

private kmlSource[char[]] kmlSources;

void initKmlSources()
{
	char[] view = cast (char[]) std.file.read( Settings.kmlPath ~ "view.template" );

	char[] all = cast (char[]) std.file.read( Settings.kmlPath ~ "all.template" );

	char[] pos_abs = cast (char[]) std.file.read( Settings.kmlPath ~ "pos_abs.template" );
	char[] pos_rel = cast (char[]) std.file.read( Settings.kmlPath ~ "pos_rel.template" );
	char[] track = cast (char[]) std.file.read( Settings.kmlPath ~ "track.template" );
	char[] projection = cast (char[]) std.file.read( Settings.kmlPath ~ "projection.template" );
	char[] index = cast (char[]) std.file.read( Settings.kmlPath ~ "index.template" );

	kmlSources["/index.kml"] = kmlSources["/"] = new kmlStaticSource(index);

	kmlSources["/view/chase"] = new chaseView_t(view);
	kmlSources["/view/chase?all"] = new chaseView_t(all);

	planeView_t planeViewLeft = new planeView_t(view);
	planeViewLeft.lookdir = -90;
	kmlSources["/view/plane?left"] = planeViewLeft;

	planeView_t planeViewRight = new planeView_t(view);
	planeViewRight.lookdir = 90;
	kmlSources["/view/plane?right"] = planeViewRight;

	kmlSources["/data/position?abs"] = new kmlDataSource(pos_abs);
	kmlSources["/data/position?rel"] = new kmlDataSource(pos_rel);
	kmlSources["/data/track"] = new kmlDataSource(track);
	kmlSources["/data/projection"] = new kmlDataSource(projection);
}

private import nmeahub;

private class kmlServer : ClientThread
{
	const char[] keyhole_headers = "HTTP/1.0 200 OK\r\nContent-Type: application/keyhole\r\nContent-Size: %s\r\n\r\n";

	this( Socket listen_socket ) {
		super(listen_socket);
	}

	void serve() {
		// do something
		switch (verb) {
		case "GET":
			if (uri == "/stream/nmea")
				HostNmeaStream();
			else
			{
				// Read the hostAddress from the http header
				char[] hostAddress;
				auto phostAddress = "Host" in fields;
				if (phostAddress)
					hostAddress = *phostAddress;

				try {
					char[] contents, retheaders;

					kmlSource* pSrc = uri in kmlSources;
					if (pSrc)
					{
						kmlSource src = *pSrc;
						synchronized( src )
						{
							src.Update();
							contents = src.kml.dup;
						}

						if (hostAddress)
							contents = std.string.replace( contents, "$hostaddress", hostAddress );
						retheaders = std.string.format( keyhole_headers, contents.length );
					}
					else
					{
						retheaders = "HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n";
						contents = "<html><title>Mooving Earth - " ~ Settings.serverName ~ " - Information</title><body><a href=\"http://" ~ hostAddress ~ "/\">Mooving Earth</a></body></html>";
					}
					client_socket.send( retheaders );
					client_socket.send( contents );
				}
				catch(Object o) {
					const string response = "HTTP/1.0 404 Not found\r\n\r\n";
					client_socket.send( response ~ "<html><body>"~o.toString~"</body></html>" );
					writefln( "Exception in GET:" );
					writefln( o.toString );
				}
			}
			break;
		default:
			const string response = "HTTP/1.0 404 Not found\r\n\r\n";
			client_socket.send( response  );
		}
	}

	void HostNmeaStream()
	{
		// Send header
		char[] retheader = "HTTP/1.0 200 OK\r\nContent-Type: text/plain\r\n\r\n";
		client_socket.send( retheader );

		// OK, ready for data
		synchronized( nmeaHub )
			nmeaHub.nmeaProcessors ~= &onNMEA;

		// Wait!
		pause();

		synchronized( nmeaHub )
		{
			// remove me!
			for (int q = 0; q<nmeaHub.nmeaProcessors.length; q++ )
			{
				if (nmeaHub.nmeaProcessors[q] !is &onNMEA)
					continue;
				nmeaHub.nmeaProcessors[q] = nmeaHub.nmeaProcessors[$-1];
				nmeaHub.nmeaProcessors.length = nmeaHub.nmeaProcessors.length - 1;
				break;
			}
		}
	}


	void onNMEA( ubyte[] nmea )
	{
		int s = client_socket.send( nmea );
		if (s == -1)
			resume();
	}
}
