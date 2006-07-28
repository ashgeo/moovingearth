module ini_win32;
private import std.string;

private import win32.winbase;
pragma ( lib, "win32.lib" );

struct Settings_t
{
	char[] kmlPath = ".\\kml\\";
	char[] logPath = ".\\log\\";
	char[] comPort = "COM2";
	char[] baudRate = "4800";
	char[] listenPort = "1234";
	char[] listenIP = "0.0.0.0";
	char[] serverName = "My PC";

	void Read() {
		ReadINIString( "KMLPath", kmlPath );
		ReadINIString( "LOGPath", logPath );
		ReadINIString( "GPSPort", comPort );
		ReadINIString( "BaudRate", baudRate );
		ReadINIString( "ListenPort", listenPort );
		ReadINIString( "ListenIP", listenIP );
		ReadINIString( "ServerName", serverName );
	}

	void Write() {
		WriteINIString( "KMLPath", kmlPath );
		WriteINIString( "LOGPath", logPath );
		WriteINIString( "GPSPort", comPort );
		WriteINIString( "BaudRate", baudRate );
		WriteINIString( "ListenPort", listenPort );
		WriteINIString( "ListenIP", listenIP );
		WriteINIString( "ServerName", serverName );
	}

	private void ReadINIString( char[] item, inout char[] value ) {
		char[1024] buffer;
		DWORD n = GetPrivateProfileString( "MoovingEarth", item.toStringz(), null, buffer.ptr, buffer.length, ".\\MoovingEarth.ini" );
		if (n > 0)
		{
			value = buffer[0..n].dup;
			return;
		}
		WriteINIString( item, value );
	}

	private bool WriteINIString( char[] item, char[] value ) {
		return 0 != WritePrivateProfileString( "MoovingEarth", item.toStringz(), value.toStringz(), ".\\MoovingEarth.ini" );
	}
}

Settings_t Settings;

static this()
{
	Settings.Read();
}
