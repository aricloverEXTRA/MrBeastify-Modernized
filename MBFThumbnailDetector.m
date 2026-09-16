#import "MBFThumbnailDetector.h"

BOOL MBFIsLikelyThumbnailView(UIView *view) {
    if (!view)
        return NO;

    /*
     * This is intentionally conservative.
     *
     * Do NOT use the old:
     *
     *     eml.timestamp
     *
     *     superview.superview
     *
     * approach here.
     *
     * The actual YouTube 20.44.2 thumbnail class should
     * be plugged into this function once identified.
     */

    NSString *className =
        NSStringFromClass(view.class);

    /*
     * Temporary diagnostic candidates.
     *
     * These are NOT claimed to be the final 20.44.2
     * thumbnail classes.
     */

    if ([className containsString:@"Thumbnail"])
        return YES;

    if ([className containsString:@"VideoThumbnail"])
        return YES;

    return NO;
}