module comm;

private import win32.core;
pragma ( lib, "win32.lib" );
private import std.string;
private import std.stdio;

class CComPort
{
	HANDLE hCom = INVALID_HANDLE_VALUE;

	~this() {
		Close();
	}

	bool Open( char[] device ) {
		// Open comms
		hCom = CreateFile( device.toStringz(),
			GENERIC_READ | GENERIC_WRITE,
			0,    // must be opened with exclusive-access
			null, // no security attributes
			OPEN_EXISTING, // must use OPEN_EXISTING
			0,    // not overlapped I/O
			null  // hTemplate must be null for comm devices
			);
		return hCom != INVALID_HANDLE_VALUE;
	}

	void Close() {
		CloseHandle(hCom);
		hCom = hCom.init;
	}

	BOOL GetState( DCB *pdcb ) {
		return GetCommState( hCom, pdcb );
	}

	BOOL SetState( DCB *pdcb ) {
		return SetCommState( hCom, pdcb );
	}

	BOOL GetTimeouts( COMMTIMEOUTS* pto ) {
		return GetCommTimeouts( hCom, pto );
	}

	BOOL SetTimeouts( COMMTIMEOUTS* pto ) {
		return SetCommTimeouts( hCom, pto );
	}

	BOOL Read( void[] buffer, DWORD *read = null ) {
		return ReadFile( hCom, buffer.ptr, buffer.length, read, null );
	}

	BOOL Write( void[] buffer, DWORD *written =null ) {
		return WriteFile( hCom, buffer.ptr, buffer.length, written, null );
	}
}

class ComPortEx : private CComPort
{
	DCB dcb;
	COMMTIMEOUTS to;

	void open( char[] dev ) {
		if (!super.Open( dev ))
			throw new Exception("open failed");
		GetState(&dcb);
		GetTimeouts(&to);
	}

	void close() {
		super.Close();
	}

	uint read( void[] buffer ) {
		DWORD _read;
		super.Read( buffer, &_read );
		return _read;
	}

	uint write( void[] buffer, DWORD *written =null ) {
		DWORD _written;
		super.Write( buffer, &_written );
		return _written;
	}

	void setState() {
		if (!super.SetState(&dcb))
			throw new Exception("SetState failed");
	}

	void setTimeouts() {
		if (!super.SetTimeouts(&to))
			throw new Exception("SetTimeouts failed");
	}

	void baud( uint br ) { dcb.BaudRate = br; setState(); }
	uint baud() { return dcb.BaudRate; }

	void readtimeout( uint rto ) { to.ReadIntervalTimeout = rto; setTimeouts(); }
	uint readtimeout() { return to.ReadIntervalTimeout; }
}
