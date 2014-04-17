//
//  ImageSpot.m
//  MySpots
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "NSString+Encryption.h"
#import "NSData+Encryption.h"
#import "UIImage+Encryption.h"
#import "FileManager.h"
#import "ImageSpot.h"
#import "Utilities.h"
#import "KeyGenerator.h"

@interface ImageSpot ()

@property (nonatomic, copy) NSMutableArray *hiddenImagePaths;
@property (nonatomic, copy) NSString *keyOfHiddenImages;

@end

@implementation ImageSpot

- (instancetype)initWithName:(NSString *)name
                    latitude:(float)latitude
                   longitude:(float)longitude
                hiddenImages:(NSArray *)hiddenImages {

    if (hiddenImages == nil) return nil;

    if (self = [super initWithName:name latitude:latitude longitude:longitude]) {
        
        _keyOfHiddenImages = [NSString randomAlphanumericStringWithLength:kLengthOfKey];
        _hiddenImagePaths = [[NSMutableArray alloc] initWithCapacity:hiddenImages.count];
        
        for (UIImage *image in hiddenImages) {
            
            UIImage *imageToSave = image;
            
            if (image.size.width > kImageDefaultWidth) {
                imageToSave = [Utilities imageWithImage:image scaledToWidth:kImageDefaultWidth];
            }
            if (imageToSave.size.height > kImageDefaultHeight) {
                imageToSave = [Utilities imageWithImage:image scaledToHeight:kImageDefaultHeight];
            }
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
            
            NSString *fileName = [[[imageToSave hashValue] stringByAppendingString:stringFromDate] stringByAppendingString:@".jpg"];
            [self.hiddenImagePaths addObject:[FileManager imageFilePathWithFileName:fileName]];
             
            [FileManager saveImageToDisk:imageToSave
                            withFileName:[fileName stringByAppendingString:kEncryptedFileSuffix]
                     usingDataEncryption:YES
                                 withKey:self.keyOfHiddenImages];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_hiddenImagePaths forKey:@"hiddenImagePaths"];
    [encoder encodeObject:_keyOfHiddenImages forKey:@"keyOfHiddenImages"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _hiddenImagePaths = [decoder decodeObjectForKey:@"hiddenImagePaths"];
        _keyOfHiddenImages = [decoder decodeObjectForKey:@"keyOfHiddenImages"];
    }
    return self;
}

- (void)decryptHiddenImagesWithCompletionBlock:(void (^)(NSArray *images))completion
{
    NSMutableArray *hiddenImages = [[NSMutableArray alloc] initWithCapacity:self.hiddenImagePaths.count];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (NSString *imagePath in self.hiddenImagePaths) {
            
            NSData *hiddenImageData = [NSData dataWithContentsOfFile:[imagePath stringByAppendingString:kEncryptedFileSuffix]];
            hiddenImageData = [hiddenImageData AES256DecryptWithKey:[KeyGenerator hiddenKeyForKey:self.keyOfHiddenImages]];
            [hiddenImages addObject:[UIImage imageWithData:hiddenImageData]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(hiddenImages);
        });
    });
}

- (void)deleteContent
{
    for (NSString *imagePath in self.hiddenImagePaths) {
        [[NSFileManager defaultManager] removeItemAtPath:[imagePath stringByAppendingString:kEncryptedFileSuffix] error:nil];
    }
}

@end
