module nmeasource;

interface NMEASource
{
	uint read( void[] buffer );
	void open( char[], uint );
}
