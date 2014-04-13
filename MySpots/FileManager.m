//
//  FileManager.m
//  MySpots
//
//  Created by Jiaqi Liu on 3/6/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "FileManager.h"
#import "KeyGenerator.h"
#import "NSString+Encryption.h"
#import "NSData+Encryption.h"
#import <CommonCrypto/CommonDigest.h>

@implementation FileManager

+ (NSString *)imageFilePathWithFileName:(NSString *)fileName
{
    return [[self class] documentsPathForFileName:fileName];
}

+ (NSString *)textFilePathWithFileName:(NSString *)fileName
{
    return [[self class] documentsPathForFileName:fileName];
}

+ (NSString *)voiceFilePathWithFileName:(NSString *)fileName
{
    return [[self class] documentsPathForFileName:fileName];
}

+ (void)saveImageToDisk:(UIImage *)image
           withFileName:(NSString *)fileName
    usingDataEncryption:(BOOL)yesOrNo
                withKey:(NSString *)key
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    if (yesOrNo) {
        if (!key) return;
        imageData = [imageData AES256EncryptWithKey:[KeyGenerator hiddenKeyForKey:key]];
    }
    
    NSString *filePath = [[self class] imageFilePathWithFileName:fileName];
    [imageData writeToFile:filePath atomically:YES];
}

+ (void)saveTextToDisk:(NSString *)text
          withFileName:(NSString *)fileName
   usingDataEncryption:(BOOL)yesOrNo
               withKey:(NSString *)key {
    
    NSData *textData = [NSData dataWithBytes: [text UTF8String] length: [text lengthOfBytesUsingEncoding: NSUTF8StringEncoding]];
    
    if (yesOrNo) {
        if (!key) return;
        textData = [textData AES256EncryptWithKey:[KeyGenerator hiddenKeyForKey:key]];
    }
    
    NSString *filePath = [[self class] imageFilePathWithFileName:fileName];
    [textData writeToFile:filePath atomically:YES];
}

+ (void)saveAudioToDisk:(NSData *)audioData
           withFileName:(NSString *)fileName
    usingDataEncryption:(BOOL)yesOrNo
                withKey:(NSString *)key {
    
    if (yesOrNo) {
        if (!key) return;
        audioData = [audioData AES256EncryptWithKey:[KeyGenerator hiddenKeyForKey:key]];
    }
    
    NSString *filePath = [[self class] imageFilePathWithFileName:fileName];
    [audioData writeToFile:filePath atomically:YES];
}

+ (NSString *)documentsPathForFileName:(NSString *)fileName
{
    return [[self documentsPath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSInteger)fileSize:(NSString*) path
{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else
    {
        return -1;
    }
}

@end
