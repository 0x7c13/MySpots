//
//  CSAboutUSViewController.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSUtilities.h"
#import "CSAboutUSViewController.h"

@interface CSAboutUSViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *codeStrikersImage;
@property (weak, nonatomic) IBOutlet UIView *csBgView;

@end

@implementation CSAboutUSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [CSUtilities addShadowToUIView:self.csBgView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exitButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
