//
//  KeyGenerator.m
//  MySpots
//
//  Created by Jiaqi Liu on 3/24/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "KeyGenerator.h"
#import "FileManager.h"
#import "NSData+Encryption.h"
#import "NSString+Encryption.h"

@implementation KeyGenerator

+ (NSString *)mainKeyForKey:(NSString *)key
{
    key = [key stringByAppendingString:@"I Love Vicky! *.*"];
    const char *cStr = [key UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result);
    NSString *mainKey = [NSString stringWithFormat:
                            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                            result[0], result[2], result[1], result[3],
                            result[6], result[7], result[12], result[9],
                            result[15], result[14], result[8], result[10],
                            result[5], result[13], result[11], result[4]
                            ];
    
    return mainKey;
}

+ (NSString *)hiddenKeyForKey:(NSString *)key
{
    key = [key stringByAppendingString:@"I Love CJ! @.@"];
    const char *cStr = [key UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result);
    NSString *mainKey = [NSString stringWithFormat:
                         @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                         result[8], result[7], result[12], result[9],
                         result[11], result[0], result[1], result[3],
                         result[15], result[10], result[2], result[4],
                         result[6], result[13], result[5], result[14]
                         ];
    
    return mainKey;
}

+ (void)saveMainKeyStringToDisk:(NSString *)string
{
    NSString *filePath = [FileManager documentsPathForFileName:[@"I Love Vicky! ~.~!" hashValue]];
    NSData *keyData = [[filePath dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:@"I Love CJ! ^.^!"];
    [keyData writeToFile:filePath atomically:YES];
}

+ (NSString *)mainKeyString
{
    NSString *filePath = [FileManager documentsPathForFileName:[@"I Love Vicky! ~.~!" hashValue]];
    NSData *keyData = [[NSData dataWithContentsOfFile:filePath] AES256DecryptWithKey:@"I Love CJ! ^.^!"];
    return [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
}

+ (NSString *)OpenUDID
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"OpenUDID"] objectForKey:@"OpenUDID"];
}

@end
