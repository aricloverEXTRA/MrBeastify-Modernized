#import "MBFOverlay.h"
#import "MBFAssets.h"
#import "Header.h"

static const NSInteger MBFOverlayTag = 0x4D4246;

BOOL MBFApplyOverlayToView(UIView *thumbnailView) {
    if (!thumbnailView)
        return NO;

    if (!TweakEnabled())
        return NO;

    // Do not add multiple overlays to the same recycled view.
    UIView *existing =
        [thumbnailView viewWithTag:MBFOverlayTag];

    if (existing)
        return YES;

    MBFAsset *asset = MBFRandomAsset();

    if (!asset || !asset.image)
        return NO;

    BOOL shouldFlip =
        arc4random_uniform(4) == 0;

    UIImage *image = asset.image;

    if (shouldFlip && asset.flippedImage) {
        image = asset.flippedImage;
    }

    UIImageView *overlay =
        [[UIImageView alloc] initWithImage:image];

    overlay.tag = MBFOverlayTag;

    /*
     * The overlay is a CHILD of thumbnailView.
     * Therefore its frame must use thumbnailView's
     * coordinate system.
     */
    overlay.frame = thumbnailView.bounds;

    overlay.autoresizingMask =
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;

    overlay.contentMode =
        UIViewContentModeScaleToFill;

    overlay.userInteractionEnabled = NO;

    if (shouldFlip && !asset.flippedImage) {
        overlay.transform =
            CGAffineTransformMakeScale(-1.0, 1.0);
    }

    [thumbnailView addSubview:overlay];

    return YES;
}

void MBFRemoveOverlayFromView(UIView *thumbnailView) {
    if (!thumbnailView)
        return;

    UIView *overlay =
        [thumbnailView viewWithTag:MBFOverlayTag];

    [overlay removeFromSuperview];
}