An application which recored at different locations the speed of 
the iphones data connection and places an overlay on a MKMapView
of varying alphas to indicate the resulting speed.

So far there is no reliable way to find out the iphones data
download speed. One possibility is to perform a speed test in app.
This is what I have worked on so far but with rubbish results.

Overlays could also be better. It would be better to use a path
of points instead of a simple circle and create a blob for places
that the tests have been run and vairy the alpha across the blob,
if possable. Maybe lots of blobs with fethered edges would work.

CoreData also need implamenting

Created for iOS 7.
