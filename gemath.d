module gemath;

public import std.math;

real deg2rad( real deg )
{
	return PI * deg / 180.0;
}

real rad2deg( real rad )
{
	return 180.0 * rad / PI;
}

real decodeNMEAtime( real nmeatime )
{
	int hours = cast(int) nmeatime / 1_00_00;
	assert( hours >= 0 );
	assert( hours < 24 );
	int mins = ( cast(int) nmeatime / 1_00 ) % 100;
	assert( mins >= 0 );
	assert( mins < 60 );
	real secs = nmeatime % 100;
	assert( secs >= 0 );
	assert( secs < 60 );
	return secs + 60 * mins + 3600 * hours;
}

