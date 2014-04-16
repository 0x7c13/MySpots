//
//  WebAPIConstants.m
//  MySpots
//
//  Created by Jiaqi Liu on 4/5/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "WebAPIConstants.h"

@implementation WebAPIConstants

NSString * const VERSION = @"1.0";

/* API PATHS */
NSString * const API_BASE_URL = @"http://camlockerapp.com/MySpot";

NSString * const API_SHARE_SPOT = @"/ShareMarker";
NSString * const API_GET_SPOT = @"/Get/";

/* PARAMS */
NSString * const PARAM_DATA = @"Data";

/* JSON PARAMS */
NSString * const PARAM_DEVICE_ID = @"deviceId";
NSString * const PARAM_SPOT_NAME = @"spotName";
NSString * const PARAM_SPOT_INFO = @"spotInfo";
NSString * const PARAM_SPOT_CONTENT = @"spotContent";

@end
