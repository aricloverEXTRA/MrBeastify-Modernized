#import <UIKit/UIKit.h>

@interface MBFAsset : NSObject

@property(nonatomic, copy, readonly) NSString *name;
@property(nonatomic, strong, readonly) UIImage *image;
@property(nonatomic, strong, readonly) UIImage *flippedImage;

- (instancetype)initWithName:(NSString *)name
                        image:(UIImage *)image
                 flippedImage:(UIImage *)flippedImage;

@end

FOUNDATION_EXPORT NSBundle *MrBeastifyBundle(void);
FOUNDATION_EXPORT NSArray<MBFAsset *> *MBFAssets(void);
FOUNDATION_EXPORT MBFAsset *MBFRandomAsset(void);