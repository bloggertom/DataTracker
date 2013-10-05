An application which recored at different locations the speed of 
the iphones data connection and places an overlay on a MKMapView
of varying alphas to indicate the resulting speed.

So far there is no reliable way to find out the iphones current data
connection type(3G/GPRS/EDGE/CDMA) progmatically. To overcome this a 
small speed test is run every time the location updates. It 
downloads a defined amount of a 5MB file taking samples of the
download speed. An average is found for these speeds and used as the
result.

Overlays could also be better. This is currently in development
it is hoped that overlays that overlap can be combined. It would
also be nice to have the edges feather out. I think this will be
possable by extending MKOverlayPathRenderer and overriding
fillPath:inContext:.

This app currently only supports 3G speeds ~ 10-15Mbs

CoreData also needs implamenting but is awayting MKOverlays to be
finished.

Created for iOS 7.
