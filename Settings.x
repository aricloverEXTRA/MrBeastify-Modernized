#import "Header.h"

#import <YouTubeHeader/YTSettingsViewController.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsSectionItemManager.h>
#import <YouTubeHeader/YTAppSettingsSectionItemActionController.h>
#import <YouTubeHeader/YTSettingsCell.h>

extern BOOL TweakEnabled(void);

static const NSInteger MrBeastifySection = 511;

@interface YTSettingsSectionItemManager (MrBeastify)

- (void)mbf_updateMrBeastifySectionWithEntry:(id)entry;

@end

%hook YTAppSettingsPresentationData

+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;

    if (!order)
        return order;

    NSMutableArray *mutableOrder =
        [order mutableCopy];

    NSUInteger insertIndex =
        [order indexOfObject:@(1)];

    if (insertIndex != NSNotFound &&
        ![order containsObject:@(MrBeastifySection)]) {

        [mutableOrder
            insertObject:@(MrBeastifySection)
            atIndex:insertIndex + 1];
    }

    return mutableOrder;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)mbf_updateMrBeastifySectionWithEntry:(id)entry {

    YTSettingsViewController *delegate =
        [self valueForKey:@"_dataDelegate"];

    if (!delegate)
        return;

    NSMutableArray *sectionItems =
        [NSMutableArray array];

    YTSettingsSectionItem *enabledSwitchItem =
        [%c(YTSettingsSectionItem)
            switchItemWithTitle:@"Enabled"
            titleDescription:@"Restart Required"
            accessibilityIdentifier:nil
            switchOn:TweakEnabled()
            switchBlock:^BOOL (
                YTSettingsCell *cell,
                BOOL enabled
            ) {

                NSUserDefaults *defaults =
                    [NSUserDefaults standardUserDefaults];

                [defaults setBool:enabled
                           forKey:EnabledKey];

                /*
                 * Do not synchronize manually.
                 * Modern NSUserDefaults handles persistence.
                 */

                return YES;
            }
            settingItemId:0];

    if (enabledSwitchItem)
        [sectionItems addObject:enabledSwitchItem];

    if ([delegate respondsToSelector:
            @selector(
                setSectionItems:
                forCategory:
                title:
                icon:
                titleDescription:
                headerHidden:)]) {

        [delegate setSectionItems:sectionItems
                      forCategory:MrBeastifySection
                            title:@"MrBeastify"
                             icon:nil
                  titleDescription:nil
                     headerHidden:NO];

    } else if ([delegate respondsToSelector:
                   @selector(
                       setSectionItems:
                       forCategory:
                       title:
                       titleDescription:
                       headerHidden:)]) {

        [delegate setSectionItems:sectionItems
                      forCategory:MrBeastifySection
                            title:@"MrBeastify"
                  titleDescription:nil
                     headerHidden:NO];
    }
}

- (void)updateSectionForCategory:(NSUInteger)category
                       withEntry:(id)entry {

    if (category == MrBeastifySection) {
        [self mbf_updateMrBeastifySectionWithEntry:entry];
        return;
    }

    %orig;
}

%end