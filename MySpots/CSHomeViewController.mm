//
//  CSHomeViewController.m
//  MySpots
//
//  Created by FlyinGeek on 11/1/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "MetaioSDKViewController.h"
#import "EAGLView.h"
#import "CSHomeViewController.h"

@interface CSHomeViewController ()

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
        
            // check username and password
        return YES;
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
