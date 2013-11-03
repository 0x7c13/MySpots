//
//  CSSpotCell.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CSSpotCell.h"

@implementation CSSpotCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    
    if (highlighted) {
        self.tagView.backgroundColor = [UIColor blackColor];

    } else {
        self.tagView.backgroundColor = self.tagColor;
    }
}

@end
