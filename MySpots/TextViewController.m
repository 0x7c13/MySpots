//
//  TextViewController.m
//  MySpots
//
//  Created by Jiaqi Liu on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "TextViewController.h"

@interface TextViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation TextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIToolbar *toolbarBackground = [[UIToolbar alloc] initWithFrame:self.view.frame];
    [self.view addSubview:toolbarBackground];
    [self.view sendSubviewToBack:toolbarBackground];
    
    [self.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor],
                                                 UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                 UITextAttributeTextShadowColor:[UIColor whiteColor],
                                                 UITextAttributeFont:[UIFont fontWithName:@"Chalkduster" size:13.0]
                                                 }];
    
    self.navigationBar.topItem.title = self.spot.name;
    self.textView.text = self.hiddenText;
    self.textView.textColor = [UIColor whiteColor];
    self.textView.font = [UIFont fontWithName:@"Chalkduster" size:20.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Text Viewing Screen";
}

- (IBAction)quitButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate dismissViewController];
    }
}


@end
