//
//  SpotsCreationTests.m
//  MySpots
//
//  Created by FlyinGeek on 4/13/14.
//  Copyright (c) 2014 CodeStrikers. All rights reserved.
//

#import "Spot.h"
#import "TextSpot.h"
#import "ImageSpot.h"
#import "AudioSpot.h"

#import "SpotsManager.h"
#import "SpotsCreationTests.h"

@implementation SpotsCreationTests

- (void)testTextSpotCreation
{
    [[SpotsManager sharedManager] removeAllSpots];
    
    Spot *newTextSpot = [[Spot alloc] initWithName:@"testSpot" latitude:20.0 longitude:-20.0];
    [[SpotsManager sharedManager] addSpot:newTextSpot withText:@"hello" completionBlock:^{
        
        
        XCTAssertTrue([SpotsManager sharedManager].spots.count == 1, @"text spot creation failed");
        
        Spot *spot = [SpotsManager sharedManager].spots[0];
        XCTAssertTrue([spot.name isEqualToString:@"testSpot"] && spot.latitude == 20.0 && spot.longitude == -20.0, @"text spot get/set failed");
        
        [(TextSpot *)spot decryptHiddenTextWithCompletionBlock:^(NSString *hiddenText){
            
            XCTAssertTrue([hiddenText isEqualToString:@"hello"], @"text spot text creation failed");
        }];

    }];
    
    
}

- (void)testImageSpotCreationTests
{
    [[SpotsManager sharedManager] removeAllSpots];
    
    Spot *newSpot2 = [[Spot alloc] initWithName:@"testSpot2" latitude:30 longitude:-30];
    [[SpotsManager sharedManager] addSpot:newSpot2 withImages:@[[UIImage imageNamed:@"bg_1.jpg"]] completionBlock:nil];
}

@end

