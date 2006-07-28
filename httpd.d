module httpd;

private import std.thread;
private import std.socket;
private import std.string;
private import std.stdio;
private import std.uri;

private import kmlserver;

version(Windows) {
pragma(lib,"ws2_32.lib");
}

alias char[] string;

class ListenThread : Thread
{
	Socket listen_socket;

	private ClientThread[] clientThreads;
	
	this() {
		//
	}

	~this() {
		delete listen_socket;
	}

	ushort port = 1234;
	char[] ip = "0.0.0.0";

	int run() {
		initKmlSources();
		listen_socket = new TcpSocket;
		listen_socket.bind( new InternetAddress( ip, port ) );
		listen_socket.listen(5);
		while (1) {
			Socket news;
			try {
				news = listen_socket.accept();
			}
			catch ( Object o )
			{
				writefln("Listen socket was closed.");
				// exit thread
				break;
			}

			// accept exits with either a socket or an exception
			assert( news );

			kmlServer ht = new kmlServer(news);

			// Remove terminated clientThreads
			for (int n = 0; n < clientThreads.length; n++ )
			{
				if (clientThreads[n].getState != Thread.TS.TERMINATED)
					continue;

				ClientThread delme = clientThreads[n];

				clientThreads[n] = clientThreads[$-1];
				clientThreads.length = clientThreads.length - 1;
				n--;

				// immediately delete?
				delete delme;
			}
			// Add this one
			clientThreads ~= ht;

			ht.start();
			assert( ht.getState == Thread.TS.RUNNING );
		}
		return 1;
	}

	void stop() {
		listen_socket.close();
		wait();
		int n;
		for ( n = 0; n < clientThreads.length; n++ )
		{
			if (clientThreads[n].getState == Thread.TS.RUNNING)
			{
				try	{
					// may be paused, hosting NMEA data...
					clientThreads[n].resume;
				} catch ( Object o ) {}
			}
		}
		writefln("Waiting for server threads to stop");
		for ( n = 0; n < clientThreads.length; n++ )
			clientThreads[n].wait;
	}
}

class ClientThread : Thread
{
	Socket client_socket;

	this( Socket listen_socket ) {
		client_socket = listen_socket;
		assert(client_socket);
	}

	int run() {
		assert(client_socket);

		string headers;
		while (1) {
			char buf[1024];
			int error = client_socket.receive( buf );
			if (error <= 0)
				break;
			headers ~= buf[0..error];
			if ((headers.length >= 2 && headers[$-2..$]=="\n\n") ||
				(headers.length >= 4 && headers[$-4..$]=="\r\n\r\n")) {
				// got headers
				parse_headers(headers);
				break;
			}
		}	

		client_socket.close();
/*
		synchronized( mainServer )
		{
			for (int n = 0; n < mainServer.clientThreads.length; n++ )
			{
				if (mainServer.clientThreads[n] != this)
					continue;

				mainServer.clientThreads[n] = mainServer.clientThreads[$-1];
				mainServer.clientThreads.length = mainServer.clientThreads.length - 1;
				writefln("Removed me from array; now there are %s threads left in it", mainServer.clientThreads.length );
				break;
			}
		}
*/
		return 1;
	}

	/// set by the parse_headers function
	string			verb, uri, ver;
	string[string]	fields;

	/// sets verb, uri, ver and fields
	void parse_headers(char[] headers)
	{
		string[] rows = headers.split("\n");
		if (rows.length == 0)
			throw new Exception("empty headers");
		// split the first line by spaces
		string[] http = rows[0].split();
		if (http.length != 3)
			throw new Exception("misformed http header");
		verb = http[0];
		uri = std.uri.decodeComponent( http[1] );
		ver = http[2];
		// split the rest by colon
		foreach(row; rows[1..$]) {
			int colon = row.find(':');
			if (colon >= 0) {
				string key = row[0..colon];
				string value = strip( row[colon+1..$] );
				fields[ key ] = value;
			}
		}
		serve();
	}

	void serve() {
const string response = "HTTP/1.0 200 OK\r\nContent-Type: text/plain\r\n\r\nNot implemented.";
		client_socket.send( response );
	}
}
