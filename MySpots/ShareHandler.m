//
//  ShareHandler.m
//  MySpots
//
//  Created by Jiaqi Liu on 4/5/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "ShareHandler.h"
#import "KeyGenerator.h"
#import "TextSpot.h"
#import "ImageSpot.h"
#import "AudioSpot.h"
#import "WebAPIConstants.h"
#import "KeyGenerator.h"
#import "SpotsManager.h"
#import "NSData+Encryption.h"

#define kAFNetworkingEnabled 1

@implementation ShareHandler


+ (void)uploadSpot:(Spot *)spot
          progress:(void (^)(NSUInteger, NSInteger))progress
   completionBlock:(void (^)(ShareHandlerOption, NSURL *, NSError *))completion
{
    NSLog(@"Spot to upload is type of :%@", [spot class]);
    
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    
    [dataDic setObject:[KeyGenerator OpenUDID] forKey:PARAM_DEVICE_ID];
    [dataDic setObject:spot.name forKey:PARAM_SPOT_NAME];
    
    if ([spot isKindOfClass:[TextSpot class]]) {
        TextSpot *textSpot = (TextSpot *)spot;
        [dataDic setObject:[[NSKeyedArchiver archivedDataWithRootObject:textSpot] base64EncodedStringWithOptions:0] forKey:PARAM_SPOT_INFO];
        [dataDic setObject:@[[[NSData dataWithContentsOfFile:[textSpot.hiddenTextPath stringByAppendingString:kEncryptedFileSuffix]] base64EncodedStringWithOptions:0]] forKey:PARAM_SPOT_CONTENT];
        
    } else if ([spot isKindOfClass:[ImageSpot class]]) {
        
        ImageSpot *imageSpot = (ImageSpot *)spot;
        [dataDic setObject:[[NSKeyedArchiver archivedDataWithRootObject:imageSpot] base64EncodedStringWithOptions:0] forKey:PARAM_SPOT_INFO];
        
        NSMutableArray *imageAry = [[NSMutableArray alloc] initWithCapacity:imageSpot.hiddenImagePaths.count];
        for (NSString *imagePath in imageSpot.hiddenImagePaths) {
            [imageAry addObject:[[NSData dataWithContentsOfFile:[imagePath stringByAppendingString:kEncryptedFileSuffix]] base64EncodedStringWithOptions:0]];
        }
        [dataDic setObject:imageAry forKey:PARAM_SPOT_CONTENT];
        
    } else if ([spot isKindOfClass:[AudioSpot class]]) {
        
        AudioSpot *audioSpot = (AudioSpot *)spot;
        [dataDic setObject:[[NSKeyedArchiver archivedDataWithRootObject:audioSpot] base64EncodedStringWithOptions:0] forKey:PARAM_SPOT_INFO];
        [dataDic setObject:@[[[NSData dataWithContentsOfFile:[audioSpot.hiddenAudioPath stringByAppendingString:kEncryptedFileSuffix]] base64EncodedStringWithOptions:0]] forKey:PARAM_SPOT_CONTENT];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDic options:kNilOptions error:nil];
    //NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    NSLog(@"File size to upload :%@", [NSByteCountFormatter stringFromByteCount:jsonData.length countStyle:NSByteCountFormatterCountStyleFile]);
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] forKey:PARAM_DATA];
    
    //NSLog(@"%@", postData);
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    NSMutableURLRequest *request =
    [serializer requestWithMethod:@"POST"
                        URLString:[API_BASE_URL stringByAppendingString:API_SHARE_SPOT]
                       parameters:postData
                            error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         
                                         NSURL *downloadURL = [NSURL URLWithString:[[NSString alloc] initWithData:responseObject
                                                                                                         encoding:NSUTF8StringEncoding]];
                                    
                                         NSLog(@"Marker uploaded!");
                                         completion(ShareHandlerOptionSuccess, downloadURL, nil);
                                         
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
                                         NSLog(@"Error occurs during uploading!");
                                         completion(ShareHandlerOptionFailure, nil, error);
                                     }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite){
        progress(totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [operation start];
}


+ (void)downloadSpotByDownloadCode:(NSString *)downloadCode
                          progress:(void (^)(NSUInteger totalBytesRead, NSInteger totalBytesExpectedToRead))progress
                   completionBlock:(void (^)(ShareHandlerOption option, NSError *error))completion
{
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];

    NSMutableURLRequest *request =
    [serializer requestWithMethod:@"GET"
                        URLString:[API_BASE_URL stringByAppendingString:[API_GET_SPOT stringByAppendingString:downloadCode]]
                       parameters:nil
                            error:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         
                                        NSDictionary *packetDic = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                                         //NSLog(@"%@", packetDic);
                                         
                                         [[self class] processSpotDataWithAttribute:packetDic completion:^(ShareHandlerOption option){
                                            
                                             if (option == ShareHandlerOptionSuccess) {
                                                 NSLog(@"Marker downloaded!");
                                                 completion(ShareHandlerOptionSuccess, nil);
                                             } else if (option == ShareHandlerOptionFailure) {
                                                 NSLog(@"Error occurs during downloading!");
                                                 completion(ShareHandlerOptionFailure, nil);
                                             }
                                         }];
                                        
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         
                                         completion(ShareHandlerOptionFailure, error);
                                     }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead){

        progress(totalBytesRead, totalBytesExpectedToRead);
    }];
    
    [operation start];
}


+ (void)processSpotDataWithAttribute:(NSDictionary *)packetDic completion:(void (^)(ShareHandlerOption option))completion
{
    if (packetDic == nil) {
        completion(ShareHandlerOptionFailure);
        return;
    }
    
    if ([packetDic objectForKey:PARAM_SPOT_INFO] == [NSNull null] || [packetDic objectForKey:PARAM_SPOT_INFO] == nil) {
        completion(ShareHandlerOptionFailure);
        return;
    }
    
    Spot *spot = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSData alloc] initWithBase64EncodedString:(NSString *)[packetDic objectForKey:PARAM_SPOT_INFO] options:0]];
    
    if (spot == nil) {
        completion(ShareHandlerOptionFailure);
        return;
    }
    
    if ([packetDic objectForKey:PARAM_SPOT_CONTENT] == [NSNull null] || [packetDic objectForKey:PARAM_SPOT_CONTENT] == nil) {
        completion(ShareHandlerOptionFailure);
        return;
    }
    
    if ([spot isKindOfClass:[TextSpot class]]) {
        NSLog(@"Text Spot Downloaded");
        NSString *hiddenText = [[NSString alloc] initWithData:[[[NSData alloc] initWithBase64EncodedString:[[packetDic objectForKey:PARAM_SPOT_CONTENT] objectAtIndex:0] options:0] AES256DecryptWithKey:[KeyGenerator hiddenKeyForKey:((TextSpot *)spot).keyOfHiddenText]] encoding:NSUTF8StringEncoding];
        
        [[SpotsManager sharedManager] addSpot:spot withText:hiddenText completionBlock:^{
            completion(ShareHandlerOptionSuccess);
        }];
        
    } else if ([spot isKindOfClass:[AudioSpot class]]) {
        NSLog(@"Audio Spot Downloaded");
        
        NSData *hiddenAudioData = [[[NSData alloc] initWithBase64EncodedString:[[packetDic objectForKey:PARAM_SPOT_CONTENT] objectAtIndex:0] options:0] AES256DecryptWithKey:[KeyGenerator hiddenKeyForKey:((AudioSpot *)spot).keyOfHiddenAudio]];
        
        [[SpotsManager sharedManager] addSpot:spot withAudioData:hiddenAudioData completionBlock:^{
            completion(ShareHandlerOptionSuccess);
        }];
        
    } else if ([spot isKindOfClass:[ImageSpot class]]) {
        NSLog(@"Image Spot Downloaded");
        
        NSMutableArray *hiddenImages = [[NSMutableArray alloc]init];
        
        NSArray *arrayOfBase64Data = [packetDic objectForKey:PARAM_SPOT_CONTENT];
        
        for (NSInteger i = 0; i < arrayOfBase64Data.count; i++) {
            UIImage *hiddenImage = [UIImage imageWithData:[[[NSData alloc] initWithBase64EncodedString:arrayOfBase64Data[i] options:0] AES256DecryptWithKey:[KeyGenerator hiddenKeyForKey:((ImageSpot *)spot).keyOfHiddenImages]]];
            [hiddenImages addObject:hiddenImage];
        }
        
        [[SpotsManager sharedManager] addSpot:spot withImages:hiddenImages completionBlock:^{
            completion(ShareHandlerOptionSuccess);
        }];
        
    }
}

@end


