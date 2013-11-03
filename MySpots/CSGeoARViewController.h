//
//  CSGeoARViewController.h
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//


#import "MetaioSDKViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

#import "CSSpot.h"

namespace metaio
{
    class IGeometry;   // forward declaration
}

@interface CSGeoARViewController : MetaioSDKViewController <CLLocationManagerDelegate>
{
    metaio::IBillboardGroup*   billboardGroup;   //!< Our default billboard group
    metaio::IGeometry* targetBillboard;
    metaio::IRadar* m_radar;
    
    UIImage* targetImage;
    
    bool locUpdate;
}

@property (nonatomic, retain) CLLocation* currentLocation;
@property (strong, nonatomic, readwrite) CSSpot *spot;


@end
