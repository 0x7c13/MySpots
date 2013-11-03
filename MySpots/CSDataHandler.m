//
//  CSDataHandler.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSDataHandler.h"
#import "Reachability.h"

#define SPOTS_CAPACITY 20


@interface CSDataHandler() {
    BOOL _isConnecting;
}

@property (nonatomic, readwrite) BOOL spotsLoaded;
@property (strong, nonatomic) NSMutableArray *spots;

@end

@implementation CSDataHandler

+ (id)sharedInstance
{
    
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init
{
    if (self = [super init]) {
        _spotsLoaded = NO;
        _isConnecting = NO;
        _spots = [[NSMutableArray alloc] initWithCapacity:SPOTS_CAPACITY];
    }
    return self;
}

- (void)connectToTheServerWithOption:(HEWebDataHandlerOption)option
{
    if (option == getWaypointsFromServer) {
        dispatch_async(kBgQueue, ^{
            NSError *error;
            NSData* data = [NSData dataWithContentsOfURL:
                            SpotsURL options:NSDataReadingUncached error:&error];
            if (!error) {
                [self performSelectorOnMainThread:@selector(getHEWaypoints:)
                                       withObject:data waitUntilDone:YES];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(connectionFailed)]) {
                        [self.delegate connectionFailed];
                    }
                    _isConnecting = NO;
                });
            }
        });
    }
    else if (option == getWaypointsFromDisk)
    {
        //...
    }
}

- (void)getHEWaypoints:(NSData *)responseData {
    
    //parse out the json data
    NSError* error;
    NSArray* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    if (!json) {
        NSLog(@"Got an error: %@", error);
        return;
    }
    
    //NSLog(@"%@", json);
    
    NSArray* latestWaypoints = json;
    
    for (NSDictionary *latestWaypoint in latestWaypoints) {
           
        NSInteger ID = [[latestWaypoint objectForKey:@"id"] integerValue];
        double lat = [[latestWaypoint objectForKey:@"lat"] doubleValue];
        double lon = [[latestWaypoint objectForKey:@"lon"] doubleValue];
        double altitude = [[latestWaypoint objectForKey:@"altitude"] doubleValue];
        double range = [[latestWaypoint objectForKey:@"range"] doubleValue];
        NSString *link = [NSString stringWithString:[latestWaypoint objectForKey:@"link"]];
        NSString *stadiumName = [NSString stringWithString:[latestWaypoint objectForKey:@"stadium_name"]];
        NSString *schoolName = [NSString stringWithString:[latestWaypoint objectForKey:@"school_name"]];
        NSString *imageURL = [NSString stringWithString:[latestWaypoint objectForKey:@"imageurl"]];
        NSString *city = [NSString stringWithString:[latestWaypoint objectForKey:@"city"]];
        NSString *state = [NSString stringWithString:[latestWaypoint objectForKey:@"state"]];
        NSString *wps = @"";


        NSString *tagColor = [NSString stringWithString:[CSUtilities hexStringFromColor:[UIColor grayColor]]];
        
        CSSpot *newSpot = [[CSSpot alloc]initWithName:stadiumName time:@"" longitude:lon latitude:lat tagColor:tagColor];
         
        [self.spots addObject:newSpot];
    }
    
    self.spotsLoaded = YES;

    if ([self.delegate respondsToSelector:@selector(spotsLoaded:)]) {
        [self.delegate spotsLoaded:self.spots];
    }

    _isConnecting = NO;
}


- (void)getSpots
{
    if (_isConnecting) return;
    
    if (self.spotsLoaded) {
        [self.delegate spotsLoaded:self.spots];
    }
    else {
        _isConnecting = YES;
        if ([CSDataHandler existNetworkConnection]) {
            [self connectToTheServerWithOption:getWaypointsFromServer];
        }
        else {
            if ([self.delegate respondsToSelector:@selector(connectionFailed)]) {
                [self.delegate connectionFailed];
            }
            _isConnecting = NO;
        }
    }
}


+ (BOOL)existNetworkConnection
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return NO;
    }
    return YES;
}

+ (void)writeSpotsToDisk:(NSMutableArray *)spots
{
    //Saving it
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:spots];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"flyingeek"];
}

+ (NSMutableArray *)loadSpotsFromDisk
{
    NSData *spotsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"flyingeek"];
    NSMutableArray *spots = [NSKeyedUnarchiver unarchiveObjectWithData:spotsData];
    return spots;
}

- (void)updateWithNewSpot:(CSSpot *)newSpot
{
    [self.spots addObject:newSpot];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.spots];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"flyingeek"];
}

#pragma --- additional useful private methods

//
//- (NSString *)convertNSDictionaryToJSONString:(NSDictionary *)jsonDictionary
//{    
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
//                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
//                                                         error:&error];
//    
//    if (!jsonData) {
//        NSLog(@"Got an error: %@", error);
//        return nil;
//    } else {
//        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        return jsonString;
//    }
//}


+ (void)uploadSpotsToServer
{
    NSError* error = nil;
    
    NSDictionary* jsonDict = @{@"id":@"613", @"username": @"wangting", @"password":@"321", @"tagname":@"spot1", @"tagcolor":@"FF6666", @"longitude":@(38.33333), @"latitude":@(83.33333)};
    
    NSArray *aryOfJson = @[jsonDict];
    
    NSData* postData = [NSJSONSerialization dataWithJSONObject:aryOfJson options:kNilOptions error:&error];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSString *jsonStr = @"[{\"id\":\"613\"}]";
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://coderhosting.com:8983/solr/collection1/update?commit=true"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    //[request setHTTPBody:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
}



@end
