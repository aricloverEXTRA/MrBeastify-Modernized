#import "MBFAssets.h"
#import "Header.h"

#import <rootless.h>

@implementation MBFAsset

- (instancetype)initWithName:(NSString *)name
                        image:(UIImage *)image
                 flippedImage:(UIImage *)flippedImage {
    self = [super init];

    if (self) {
        _name = [name copy];
        _image = image;
        _flippedImage = flippedImage;
    }

    return self;
}

@end

NSBundle *MrBeastifyBundle(void) {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *bundlePath =
            [[NSBundle mainBundle] pathForResource:TweakName
                                             ofType:@"bundle"];

        if (!bundlePath) {
            bundlePath =
                ROOT_PATH_NS(@"/Library/Application Support/"
                             TweakName
                             @".bundle");
        }

        bundle = [NSBundle bundleWithPath:bundlePath];
    });

    return bundle;
}

static NSArray<MBFAsset *> *LoadAssets(void) {
    NSBundle *bundle = MrBeastifyBundle();

    if (!bundle) {
        NSLog(@"[MrBeastify] Unable to locate bundle");
        return @[];
    }

    NSString *bundlePath = bundle.bundlePath;

    NSFileManager *fileManager =
        [NSFileManager defaultManager];

    NSArray<NSString *> *files =
        [fileManager contentsOfDirectoryAtPath:bundlePath
                                         error:nil];

    NSMutableArray<MBFAsset *> *assets =
        [NSMutableArray array];

    for (NSString *file in files) {
        NSString *extension =
            file.pathExtension.lowercaseString;

        if (![extension isEqualToString:@"png"])
            continue;

        NSString *name =
            file.stringByDeletingPathExtension;

        // Main assets must be numeric.
        NSInteger number = name.integerValue;

        if (number <= 0)
            continue;

        NSString *imagePath =
            [bundlePath stringByAppendingPathComponent:file];

        UIImage *image =
            [UIImage imageWithContentsOfFile:imagePath];

        if (!image)
            continue;

        UIImage *flippedImage = nil;

        NSString *flippedPath =
            [[bundlePath
                stringByAppendingPathComponent:@"textFlipped"]
                stringByAppendingPathComponent:file];

        if ([fileManager fileExistsAtPath:flippedPath]) {
            flippedImage =
                [UIImage imageWithContentsOfFile:flippedPath];
        }

        MBFAsset *asset =
            [[MBFAsset alloc]
                initWithName:name
                image:image
                flippedImage:flippedImage];

        [assets addObject:asset];
    }

    [assets sortUsingComparator:^NSComparisonResult(
        MBFAsset *a,
        MBFAsset *b
    ) {
        NSInteger first = a.name.integerValue;
        NSInteger second = b.name.integerValue;

        if (first < second)
            return NSOrderedAscending;

        if (first > second)
            return NSOrderedDescending;

        return NSOrderedSame;
    }];

    NSLog(@"[MrBeastify] Loaded %lu assets",
          (unsigned long)assets.count);

    return [assets copy];
}

NSArray<MBFAsset *> *MBFAssets(void) {
    static NSArray<MBFAsset *> *assets;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        assets = LoadAssets();
    });

    return assets;
}

MBFAsset *MBFRandomAsset(void) {
    NSArray<MBFAsset *> *assets = MBFAssets();

    if (assets.count == 0)
        return nil;

    NSUInteger index =
        arc4random_uniform((uint32_t)assets.count);

    return assets[index];
}