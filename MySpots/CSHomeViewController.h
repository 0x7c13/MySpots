//
//  CSHomeViewController.h
//  MySpots
//
//  Created by FlyinGeek on 11/1/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASDepthModalViewController.h"

@interface CSHomeViewController : UIViewController <ASDepthModalViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *loginViewBG;

@property (strong, nonatomic) ASDepthModalViewController *popManagerVC;
@end
