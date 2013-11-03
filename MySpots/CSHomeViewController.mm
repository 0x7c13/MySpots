//
//  CSHomeViewController.m
//  MySpots
//
//  Created by FlyinGeek on 11/1/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSUtilities.h"
#import "CSUser.h"
#import "MetaioSDKViewController.h"
#import "EAGLView.h"
#import "CSHomeViewController.h"

@interface CSHomeViewController () {
    BOOL welcomeAnimationExecuted;
}

@property (weak, nonatomic) IBOutlet UIView *titleBgView;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UIView *signinBgView;
@property (weak, nonatomic) IBOutlet UIView *addASpotBgView;
@property (weak, nonatomic) IBOutlet UIView *viewMySpotsBgView;
@property (weak, nonatomic) IBOutlet UIView *aboutUsBgView;
@property (weak, nonatomic) IBOutlet UIView *codeStrikersBgView;


@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@property (weak, nonatomic) IBOutlet UIButton *addASpotButton;
@property (weak, nonatomic) IBOutlet UIButton *viewMySpotsButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutUsButton;


@end

@implementation CSHomeViewController

- (ASDepthModalViewController *)popManagerVC
{
    if (!_popManagerVC) {
        _popManagerVC = [[ASDepthModalViewController alloc]init];
        _popManagerVC.delegate = self;
    }
    return _popManagerVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.loginViewBG.layer.cornerRadius = 8;
    [self.loginViewBG.layer setMasksToBounds:YES];
    
    self.popupView.layer.cornerRadius = 12;
    self.popupView.layer.shadowOpacity = 0.7;
    self.popupView.layer.shadowOffset = CGSizeMake(6.0f, 6.0f);
    [self.popupView.layer setShadowRadius:6.0];
    self.popupView.layer.shouldRasterize = YES;
    self.popupView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    welcomeAnimationExecuted = NO;
    
    [CSUtilities addShadowToUIView:self.titleBgView];
    [CSUtilities addShadowToUIView:self.signinBgView];
    [CSUtilities addShadowToUIView:self.addASpotBgView];
    [CSUtilities addShadowToUIView:self.viewMySpotsBgView];
    [CSUtilities addShadowToUIView:self.aboutUsBgView];
    [CSUtilities addShadowToUIView:self.codeStrikersBgView];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    
    CSUser *currentUser = [CSUser sharedInstance];
    if(currentUser.isGuest) {
        self.accountLabel.text = @"";
        welcomeAnimationExecuted = NO;
    }
    else {
        if (!welcomeAnimationExecuted) {
            self.accountLabel.alpha = 0.0f;
            self.accountLabel.text = [NSString stringWithFormat:@"Welcome, %@", [currentUser getUsername]];
            
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{ self.accountLabel.alpha = 1.0f; }
                             completion:^(BOOL finished) {
                                 self.accountLabel.alpha = 1.0f;
                                welcomeAnimationExecuted = YES;
                             }];
            
        }
    }
}

- (IBAction)loginButtonPressed:(id)sender {

    if ([self loginCheck]) {
        [self.popManagerVC dismiss];
    }
    else {
        // shake
        [self shakeWithDuration:0.1f];
    }
}

- (BOOL)loginCheck
{

    if (![self.usernameTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""]) {
        
        CSUser *currentUser = [CSUser sharedInstance];
        if (currentUser.isGuest) {
            if([currentUser loginWithUsername:self.usernameTextField.text password:self.passwordTextField.text]) {
                return YES;
            }else {
                return NO;
            }
        }
        else return NO;
    }


    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shakeWithDuration:(NSTimeInterval)animationTime
{
    CGFloat t = 4.0;
    
    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity,-t, 0);
    
    self.popupView.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:nil];
    [UIView setAnimationRepeatAutoreverses:YES];    // important
    [UIView setAnimationRepeatCount:2];
    [UIView setAnimationDuration:animationTime];
    [UIView setAnimationDelegate:self];
    //[UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    self.popupView.transform = rightQuake;    // end here & auto-reverse
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    
    if ([self loginCheck]) {
        [self.popManagerVC dismiss];
    }
    else {
        // shake
        [self shakeWithDuration:0.1f];
    }
    
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    NSTimeInterval animationDuration = 0.20f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.popupView.frame.size.width, self.popupView.frame.size.height);
    self.popupView.frame = rect;
    [UIView commitAnimations];
    return YES;
}

#pragma -- protocal

- (void)popupViewDidDisappear:(ASDepthModalViewController *)sender
{
    //...
    
}

- (void)userDidDismissPopupView:(ASDepthModalViewController *)sender
{
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
    
}


- (void)addShadow: (UIImageView *)view
{
    [view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view.layer setShadowOffset:CGSizeMake(0.0f, 5.0f)];
    [view.layer setShadowOpacity:0.4];
    [view.layer setShadowRadius:6.0];
    
    // improve performance
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowPath = path.CGPath;
}

- (IBAction)signinButtonPressed:(id)sender {
    
    
    [self.popManagerVC presentView:self.popupView withBackgroundColor:nil popupAnimationStyle:ASDepthModalAnimationShrink];

}

- (IBAction)usernameTextFieldTouchDown:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)passwordTextFieldTouchDown:(id)sender {
    [sender resignFirstResponder];
}


@end
