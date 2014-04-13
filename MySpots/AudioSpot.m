//
//  AudioSpot.m
//  MySpots
//
//  Created by Jiaqi Liu on 3/31/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "NSString+Encryption.h"
#import "FileManager.h"
#import "AudioSpot.h"
#import "KeyGenerator.h"
#import "NSData+Encryption.h"

@interface AudioSpot ()

@property (nonatomic, copy) NSString *hiddenAudioPath;
@property (nonatomic, copy) NSString *keyOfHiddenAudio;

@end

@implementation AudioSpot

- (instancetype)initWithName:(NSString *)name
                    latitude:(float)latitude
                   longitude:(float)longitude
                 hiddenAudio:(NSData *)hiddenAudioData {

    if (!(hiddenAudioData)) return nil;
    
    if ((self = [super initWithName:name latitude:longitude longitude:longitude])) {
        
        _keyOfHiddenAudio = [NSString randomAlphanumericStringWithLength:kLengthOfKey];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
        
        NSString *fileName = [[[hiddenAudioData hashValue] stringByAppendingString:stringFromDate] stringByAppendingString:@".aac"];
        
        self.hiddenAudioPath = [FileManager textFilePathWithFileName:fileName];
        
        [FileManager saveAudioToDisk:hiddenAudioData
                        withFileName:[fileName stringByAppendingString:kEncryptedFileSuffix]
                 usingDataEncryption:YES
                             withKey:self.keyOfHiddenAudio];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_hiddenAudioPath forKey:@"hiddenAudioPath"];
    [encoder encodeObject:_keyOfHiddenAudio forKey:@"keyOfHiddenAudio"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _hiddenAudioPath = [decoder decodeObjectForKey:@"hiddenAudioPath"];
        _keyOfHiddenAudio = [decoder decodeObjectForKey:@"keyOfHiddenAudio"];
    }
    return self;
}

- (void)decryptHiddenAudioWithCompletionBlock:(void (^)(NSData *hiddenAudioData))completion
{
    NSData *hiddenAudioData = [NSData dataWithContentsOfFile:[self.hiddenAudioPath stringByAppendingString:kEncryptedFileSuffix]];
    hiddenAudioData = [hiddenAudioData AES256DecryptWithKey:[KeyGenerator hiddenKeyForKey:self.keyOfHiddenAudio]];
    completion(hiddenAudioData);
}

- (void)deleteContent
{
    [[NSFileManager defaultManager] removeItemAtPath:[self.hiddenAudioPath stringByAppendingString:kEncryptedFileSuffix] error:nil];
}

@end