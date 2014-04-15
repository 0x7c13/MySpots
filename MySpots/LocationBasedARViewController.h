
//  metaio SDK
//
// Copyright 2007-2013 metaio GmbH. All rights reserved.
//

#import "TSMessage.h"
#import "MetaioSDKViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

namespace metaio
{
    class IGeometry;   // forward declaration
}

@interface LocationBasedARViewController : MetaioSDKViewController <CLLocationManagerDelegate>
{	
    metaio::IBillboardGroup*   billboardGroup;   //!< Our default billboard group
    metaio::IGeometry* targetBillboard;
    metaio::IRadar* m_radar;
    
    UIImage* targetImage;
}

@end
