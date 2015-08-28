GPS moving map for google earth.
Small 'webserver' that reads and logs GPS input, and serves various KML/KMZ 'files' to output current position, heading, track-log, various views to Google Earth.

Current Inputs:
**Serial/bluetooth GPS receiver outputting NMEA,** NMEA over UDP packets.

Outputs:
**NMEA over UDP** NMEA to file
**NMEA over HTTP text** Various and configurable KML (google Earth) outputs over HTTP