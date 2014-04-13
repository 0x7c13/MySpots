//
//  SpotTypeChosenViewController.m
//  MySpots
//
//  Created by Jiaqi Liu on 3/21/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "Utilities.h"
#import "SpotTypeChosenViewController.h"
#import "UIColor+MLPFlatColors.h"

@interface SpotTypeChosenViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;

@end

@implementation SpotTypeChosenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Utilities addBackgroundImageToView:self.view withImageName:@"bg_1.jpg"];
    [Utilities makeTransparentBarsForViewController:self];
    
    [self.imageButton.layer addSublayer:[Utilities addDashedBorderToView:self.imageButton
                                                               withColor:[UIColor flatWhiteColor].CGColor]];
    [self.textButton.layer addSublayer:[Utilities addDashedBorderToView:self.textButton
                                                              withColor:[UIColor flatWhiteColor].CGColor]];
    [self.voiceButton.layer addSublayer:[Utilities addDashedBorderToView:self.voiceButton
                                                               withColor:[UIColor flatWhiteColor].CGColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Spot Type Chosen Screen";
}

@end
