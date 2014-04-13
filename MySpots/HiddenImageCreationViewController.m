//
//  HiddenImageCreationViewController.m
//  MySpots
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "Utilities.h"
#import "SpotsManager.h"
#import "DataHandler.h"
#import "HiddenImageCreationViewController.h"
#import "SWSnapshotStackView.h"
#import "JDStatusBarNotification.h"
#import "ETActivityIndicatorView.h"
#import "UIColor+MLPFlatColors.h"
#import "SIAlertView.h"
#import "PhotoStackView.h"
#import "TSMessage.h"
#import "ANBlurredImageView.h"
#import "URBMediaFocusViewController.h"
#import "MHNatGeoViewControllerTransition.h"
#import "UIView+Genie.h"
#import "UIKit+AFNetworking.h"
#import "THProgressView.h"


@interface HiddenImageCreationViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoStackViewDataSource, PhotoStackViewDelegate, URBMediaFocusViewControllerDelegate> {
    BOOL isEncrypting;
    BOOL canExit;
}

@property (nonatomic) NSMutableArray *hiddenImages;
@property (nonatomic) NSMutableArray *photos;
@property (nonatomic) URBMediaFocusViewController *mediaFocusController;

@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet ANBlurredImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet PhotoStackView *photoStack;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addMoreButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;
@property (weak, nonatomic) IBOutlet THProgressView *progressView;

@end

@implementation HiddenImageCreationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.mediaFocusController = [[URBMediaFocusViewController alloc] init];
	self.mediaFocusController.delegate = self;
    
    [Utilities addBackgroundImageToView:self.masterView withImageName:@"bg_1.jpg"];
    
    canExit = NO;
    isEncrypting = NO;
    
    _hiddenImages = [[NSMutableArray alloc]init];
    _photos = [[NSMutableArray alloc]init];
    
    _photoStack.dataSource = self;
    _photoStack.delegate = self;
    self.photoStack.hidden = YES;
    self.pageControl.hidden = YES;
    self.progressView.hidden = YES;
    self.trashButton.enabled = NO;
    self.addMoreButton.enabled = NO;
    
    self.progressView.borderTintColor = [UIColor whiteColor];
    self.progressView.progressTintColor = [UIColor whiteColor];
    
    [_imageView setHidden:YES];
    [_imageView setFramesCount:8];
    [_imageView setBlurAmount:1];
    
    self.addImageButton.layer.cornerRadius = 15;

    // 3.5-inch iPhone tweaks
    {
        CGFloat yOffset = DEVICE_IS_4INCH_IPHONE ? 0 : -65;
        
        self.addImageButton.frame = CGRectMake(self.addImageButton.frame.origin.x, self.addImageButton.frame.origin.y, self.addImageButton.frame.size.width, self.addImageButton.frame.size.height + yOffset);
        
        self.photoStack.frame = CGRectMake(self.photoStack.frame.origin.x, self.photoStack.frame.origin.y, self.photoStack.frame.size.width, self.photoStack.frame.size.height + yOffset);
        
        self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y + yOffset, self.progressView.frame.size.width, self.progressView.frame.size.height);
        
        [self.addImageButton.layer addSublayer:[Utilities addDashedBorderToView:self.addImageButton
                                                                        withColor:[UIColor flatWhiteColor].CGColor]];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Hidden Image Creation Screen";
}

- (IBAction)trashButtonPressed:(id)sender {
    
    self.photoStack.userInteractionEnabled = NO;
    self.addMoreButton.enabled = NO;
    self.doneButton.enabled = NO;
    
    if (self.photos.count == 1) {
        [UIView animateWithDuration:1.0f animations:^{
            self.pageControl.alpha = 0.0f;
        } completion:^(BOOL finished){
            self.pageControl.hidden = YES;
        }];
    }
    [[self.photoStack topPhoto] genieInTransitionWithDuration:0.7
                                              destinationRect:CGRectMake(135, self.view.frame.size.height - 40, 1, 1)
                                              destinationEdge:BCRectEdgeTop
                                                   completion:^{
                                                      
                                                       [self.photos removeObjectAtIndex:self.pageControl.currentPage];
                                                       [self.hiddenImages removeObjectAtIndex:self.pageControl.currentPage];

                                                       [self.photoStack reloadData];
                                                       
                                                       if (self.pageControl.currentPage == self.pageControl.numberOfPages - 1) {
                                                           self.pageControl.numberOfPages--;
                                                           self.pageControl.currentPage = 0;
                                                       } else {
                                                           self.pageControl.numberOfPages--;
                                                       }
                                                       
                                                       self.photoStack.userInteractionEnabled = YES;
                                                       self.addMoreButton.enabled = YES;
                                                       self.doneButton.enabled = YES;
                                                       
                                                       if (self.hiddenImages.count == 0) {
                                                           
                                                           self.photoStack.hidden = YES;
                                                           self.trashButton.enabled = NO;
                                                           self.addMoreButton.enabled = NO;
                                                           self.pageControl.alpha = 0.3f;
                                                           self.addImageButton.alpha = 0.0f;
                                                           self.addImageButton.hidden = NO;
                                                           
                                                           [UIView animateWithDuration:1.0f animations:^{
                                                               self.addImageButton.alpha = 0.5f;
                                                           } completion:nil];
                                                       }
                                                   }];

}

- (IBAction)addImageButtonPressed:(id)sender {
    
    if (isEncrypting) return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)addMoreButtonPressed:(id)sender {
    
    if (isEncrypting || self.hiddenImages.count == 0) return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:picker animated:YES completion:nil];
}


- (IBAction)doneButtonPressed:(id)sender {
    
    if (canExit) {
        [SpotsManager sharedManager].tempSpot = nil;
        [self.navigationController dismissNatGeoViewController];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        return;
    }
    if (isEncrypting) return;
    if (self.photos.count == 0) {
        
        [TSMessage showNotificationInViewController:self title:@"Oops"
                                           subtitle:@"Please add some images!"
                                               type:TSMessageNotificationTypeError
                                           duration:1.5f
                               canBeDismissedByUser:YES];
        return;
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Almost there" andMessage:@"Are you ready to create this spot?"];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              
                              if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                                  self.navigationController.interactivePopGestureRecognizer.enabled = NO;
                              }
                              self.navigationItem.hidesBackButton = YES;
                              self.trashButton.enabled = NO;
                              self.doneButton.enabled = NO;
                              self.addMoreButton.enabled = NO;
                              
                              isEncrypting = YES;
                              self.imageView.hidden = NO;
                              self.imageView.image = [Utilities snapshotViewForView:self.masterView];
                              self.imageView.baseImage = self.imageView.image;
                              
                              [self.imageView setBlurTintColor:[UIColor colorWithWhite:0.f alpha:0.5]];
                              [self.imageView generateBlurFramesWithCompletionBlock:^{
                                  
                                  [self.imageView blurInAnimationWithDuration:0.3f];
                                  
                                  self.photoStack.userInteractionEnabled = NO;
                                  ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height/2 -30, 60, 60)];
                                  etActivity.color = [UIColor flatWhiteColor];
                                  [etActivity startAnimating];
                                  [self.view addSubview:etActivity];
                                  [JDStatusBarNotification showWithStatus:@"Encrypting Data..." styleName:JDStatusBarStyleError];
                                  
                                  [[SpotsManager sharedManager] addSpotWithImages:self.hiddenImages
                                                                  completionBlock:^{
                                                                                 
                                                                     [JDStatusBarNotification dismiss];
                                                                     [self uploadSpot];
                                                                     [etActivity removeFromSuperview];
                                                                }];
                              }];

                              
    }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
    alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
    alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    [alertView show];
}

- (void)uploadSpot
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Share" andMessage:@"Would you like to share this spot with your friends? You can upload it to our server and share it with your friends!"];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              
                              [JDStatusBarNotification showWithStatus:@"New spot created!" dismissAfter:1.5f styleName:JDStatusBarStyleSuccess];
                              [SpotsManager sharedManager].tempSpot = nil;
                              [self.navigationController dismissNatGeoViewController];
                              self.navigationController.navigationBar.userInteractionEnabled = YES;
                              
                          }];
    [alertView addButtonWithTitle:@"Upload"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              
                              ETActivityIndicatorView *etActivity = [[ETActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30, self.view.frame.size.height/2 -30, 60, 60)];
                              etActivity.color = [UIColor flatWhiteColor];
                              [etActivity startAnimating];
                              [self.view addSubview:etActivity];

                              [JDStatusBarNotification showWithStatus:@"Uploading spot..." styleName:JDStatusBarStyleError];

                              self.progressView.progress = 0.0f;
                              self.progressView.alpha = 0.0f;
                              self.progressView.hidden = NO;
                              [UIView animateWithDuration:0.3f animations:^{
                                  self.progressView.alpha = 1.0f;
                              }];
                              
                              /*
                              [DataHandler uploadSpot:[[SpotsManager sharedManager].spots lastObject]
                                                 progress:^(NSUInteger bytesWritten, NSInteger totalBytesWritten){
                                                     [self.progressView setProgress:(double)bytesWritten/(double)totalBytesWritten animated:YES];
                                                 }
                                          completionBlock:^(DataHandlerOption option, NSURL *spotURL, NSError *error){
                                  
                                  [etActivity removeFromSuperview];
                                  [JDStatusBarNotification showWithStatus:@"Spot uploaded!" dismissAfter:2.0f styleName:JDStatusBarStyleSuccess];
                                  
                                  [UIView animateWithDuration:0.3f animations:^{
                                      self.progressView.alpha = 0.0f;
                                      self.progressView.hidden = YES;
                                  }];
                                              
                                  if (option == DataHandlerOptionSuccess) {
                                      
                                      NSLog(@"%@", spotURL);
                                  } else {
                                      NSLog(@"%@", error.localizedDescription);
                                  }
                                  
                                  [self showShareMenuWithDownloadURL:spotURL];
                              }];
                               */
                              
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.titleFont = [UIFont fontWithName:@"OpenSans" size:25.0];
    alertView.messageFont = [UIFont fontWithName:@"OpenSans" size:15.0];
    alertView.buttonFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    [alertView show];
}

- (void)executeAnimation
{
    self.photoStack.userInteractionEnabled = NO;
    UIView *targetView =  [self.photoStack topPhoto];
    targetView.alpha = 0.0f;
    [UIView animateWithDuration:0.7f animations:^{
        targetView.alpha = 1.0f;
    } completion:^(BOOL finished){
        self.photoStack.userInteractionEnabled = YES;
    }];
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)showShareMenuWithDownloadURL:(NSURL *)spotURL
{
    canExit = YES;
    self.doneButton.enabled = YES;
    [super showShareMenuWithDownloadURL:spotURL];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [self.hiddenImages insertObject:chosenImage atIndex:self.pageControl.currentPage];
    
    UIImage *croppedImage = [Utilities imageWithImage:chosenImage scaledToWidth:220 + arc4random() % 35];
    if (croppedImage.size.height > self.photoStack.frame.size.height) {
        croppedImage = [Utilities imageWithImage:croppedImage scaledToHeight:self.photoStack.frame.size.height - 10];
    }
    [self.photos insertObject:croppedImage atIndex:self.pageControl.currentPage];
    [self.photoStack reloadData];
     self.pageControl.numberOfPages = [self.photos count];
    // self.photoStack.alpha = 0.0f;
    self.photoStack.hidden = NO;
    self.pageControl.hidden = NO;
    self.addImageButton.hidden = YES;
    self.trashButton.enabled = YES;
    self.addMoreButton.enabled = YES;
    
    [self executeAnimation];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark -
#pragma mark Deck DataSource Protocol Methods

-(NSUInteger)numberOfPhotosInPhotoStackView:(PhotoStackView *)photoStack {
    return [self.photos count];
}

-(UIImage *)photoStackView:(PhotoStackView *)photoStack photoForIndex:(NSUInteger)index {
    return [self.photos objectAtIndex:index];
}


#pragma mark -
#pragma mark Deck Delegate Protocol Methods

-(void)photoStackView:(PhotoStackView *)photoStackView willStartMovingPhotoAtIndex:(NSUInteger)index {
    // User started moving a photo
}

-(void)photoStackView:(PhotoStackView *)photoStackView willFlickAwayPhotoFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    // User flicked the photo away, revealing the next one in the stack
}

-(void)photoStackView:(PhotoStackView *)photoStackView didRevealPhotoAtIndex:(NSUInteger)index {
    self.pageControl.currentPage = index;
}

-(void)photoStackView:(PhotoStackView *)photoStackView didSelectPhotoAtIndex:(NSUInteger)index {
    NSLog(@"selected %d", index);
    [self.mediaFocusController showImage:self.hiddenImages[index] fromView:photoStackView];
}


@end
