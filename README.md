#DataTracker

An application which recored at different locations the speed of 
the iphones data connection and places an overlay on a MKMapView
of varying alphas to indicate the resulting speed.

So far there is no reliable way to find out the iphones current data
connection type(3G/GPRS/EDGE/CDMA) progmatically. Therefore  a 
small speed test is run every time the location updates. It 
downloads a defined amount of a 5MB file taking samples of the
download speed. An average is found for these speeds and used as the
result.

##To do

This app currently only supports 3G speeds ~ 10-15Mbs

Add anitation to overlays to see the resulting speed when tapped

Created for iOS 7.
