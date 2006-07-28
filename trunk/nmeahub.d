module nmeahub;

alias void delegate( ubyte[] ) nmeaProcessor;

class nmeaHub_t
{
	void onNMEA( ubyte[] nmea )
	{
		foreach ( nP; nmeaProcessors )
			nP( nmea );
	}

	nmeaProcessor[] nmeaProcessors;

	private this() {}
}

nmeaHub_t nmeaHub;

static this()
{
	nmeaHub = new nmeaHub_t;
}
