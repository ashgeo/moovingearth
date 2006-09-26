﻿module udpgps;

private import std.socket;
private import nmeasource;
private import std.stdio;

class UDPGPS : public NMEASource
{
	private Socket listen_socket;

	void open( char[] ip, uint _port ) {
		if (!ip.length)
			throw new Exception("Invalid UDP IP");
		writefln( "Starting UDP" );
		ushort port = cast (ushort) _port;
		listen_socket = new UdpSocket;
		listen_socket.bind( new InternetAddress( ip, port ) );
		writefln( "Starting UDP" );
	}

	uint read( void[] buffer ) {
		return listen_socket.receiveFrom( buffer );
	}
}

private import nmeahub;

class nmeaBroadcaster
{
	private Socket send_socket;
	private InternetAddress send_address;

	this( char[] ip, uint port ) {
		send_socket = new UdpSocket;
		send_address = new InternetAddress( ip, cast (ushort) port );

		// OK, ready for data
		synchronized( nmeaHub )
			nmeaHub.nmeaProcessors ~= &onNMEA;
	}

	void onNMEA( ubyte[] data ) {
		try {
			send_socket.sendTo( data, send_address ); 
		}
		catch
		{
			writefln( "Could not send NMEA to server" );
		}
	}

}