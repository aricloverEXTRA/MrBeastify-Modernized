#import <UIKit/UIKit.h>

#import "Header.h"
#import "MBFAssets.h"
#import "MBFOverlay.h"
#import "MBFThumbnailDetector.h"

#import <YouTubeHeader/ELMView.h>
#import <YouTubeHeader/ELMNodeController.h>

BOOL TweakEnabled(void) {
    NSUserDefaults *defaults =
        [NSUserDefaults standardUserDefaults];

    if ([defaults objectForKey:EnabledKey] != nil)
        return [defaults boolForKey:EnabledKey];

    return YES;
}

/*
 * PoomSmart's YouTube tweaks use this general ELM
 * controller/materialized-instance pattern.
 *
 * This is useful for investigating modern YouTube's
 * UI hierarchy without relying on the old
 * _ASDisplayView/eml.timestamp implementation.
 */
static ELMNodeController *MBFNodeControllerForELMView(
    ELMView *elmView
) {
    if (!elmView)
        return nil;

    id controller = nil;

    @try {
        controller =
            [elmView valueForKey:@"_strongRootController"];

        if (!controller) {
            controller =
                [elmView valueForKey:@"_rootController"];
        }
    }
    @catch (NSException *exception) {
        return nil;
    }

    if (!controller)
        return nil;

    if ([controller respondsToSelector:
            @selector(materializedInstance)]) {

        id materialized =
            [controller materializedInstance];

        if (materialized)
            controller = materialized;
    }

    if ([controller
            isKindOfClass:%c(ELMNodeController)]) {

        return controller;
    }

    return nil;
}

/*
 * Diagnostic ELM hook.
 *
 * This deliberately does NOT inject MrBeast yet.
 * Its purpose is to identify the actual materialized
 * thumbnail node/view used by YouTube 20.44.2.
 */
%hook ELMView

- (void)didMoveToWindow {
    %orig;

    if (!TweakEnabled())
        return;

    ELMNodeController *controller =
        MBFNodeControllerForELMView(self);

    if (!controller)
        return;

    NSLog(
        @"[MrBeastify] ELMView=%@ controller=%@ "
         "materialized=%@ frame=%@",
        self,
        controller,
        [controller materializedInstance],
        NSStringFromCGRect(self.frame)
    );
}

%end

%ctor {
    /*
     * Force asset discovery during initialization so
     * malformed/missing assets are detected early.
     */
    MBFAssets();

    NSLog(
        @"[MrBeastify] initialized - assets=%lu",
        (unsigned long)MBFAssets().count
    );
}