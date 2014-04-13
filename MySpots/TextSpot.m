//
//  TextSpot.m
//  MySpots
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "NSString+Encryption.h"
#import "FileManager.h"
#import "TextSpot.h"
#import "KeyGenerator.h"
#import "NSData+Encryption.h"

@interface TextSpot ()

@property (nonatomic, copy) NSString *hiddenTextPath;
@property (nonatomic, copy) NSString *keyOfHiddenText;

@end

@implementation TextSpot

- (instancetype)initWithName:(NSString *)name
                    latitude:(float)latitude
                   longitude:(float)longitude
                  hiddenText:(NSString *)hiddenText {
    
    if ((self = [super initWithName:name latitude:latitude longitude:longitude])) {
        
        _keyOfHiddenText = [NSString randomAlphanumericStringWithLength:kLengthOfKey];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
        
        NSString *fileName = [[[hiddenText hashValue] stringByAppendingString:stringFromDate] stringByAppendingString:@".txt"];
        
        self.hiddenTextPath = [FileManager textFilePathWithFileName:fileName];
        
        [FileManager saveTextToDisk:hiddenText
                       withFileName:[fileName stringByAppendingString:kEncryptedFileSuffix]
                usingDataEncryption:YES
                            withKey:self.keyOfHiddenText];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_hiddenTextPath forKey:@"hiddenTextPath"];
    [encoder encodeObject:_keyOfHiddenText forKey:@"keyOfHiddenText"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _hiddenTextPath = [decoder decodeObjectForKey:@"hiddenTextPath"];
        _keyOfHiddenText = [decoder decodeObjectForKey:@"keyOfHiddenText"];
    }
    return self;
}

- (void)decryptHiddenTextWithCompletionBlock:(void (^)(NSString *hiddenText))completion
{
    NSData *hiddenTextData = [NSData dataWithContentsOfFile:[self.hiddenTextPath stringByAppendingString:kEncryptedFileSuffix]];
    hiddenTextData = [hiddenTextData AES256DecryptWithKey:[KeyGenerator hiddenKeyForKey:self.keyOfHiddenText]];
    NSString *hiddenText = [[NSString alloc] initWithData:hiddenTextData encoding:NSUTF8StringEncoding];
    completion(hiddenText);
}

- (void)deleteContent
{
    [[NSFileManager defaultManager] removeItemAtPath:[self.hiddenTextPath stringByAppendingString:kEncryptedFileSuffix] error:nil];
}

@end
