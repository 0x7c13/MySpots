//
//  ImageViewController.m
//  MySpots
//
//  Created by Jiaqi Liu on 3/4/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "ImageViewController.h"
#import "PhotoStackView.h"
#import "Utilities.h"
#import "URBMediaFocusViewController.h"

@interface ImageViewController () <PhotoStackViewDelegate, PhotoStackViewDataSource, URBMediaFocusViewControllerDelegate>

@property (nonatomic) NSMutableArray *photos;
@property (nonatomic) URBMediaFocusViewController *mediaFocusController;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet PhotoStackView *photoStack;

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIToolbar *toolbarBackground = [[UIToolbar alloc] initWithFrame:self.view.frame];

    [self.view addSubview:toolbarBackground];
    [self.view sendSubviewToBack:toolbarBackground];
 
    self.navigationBar.topItem.title = self.spot.name;
    
    _photos = [[NSMutableArray alloc] initWithCapacity:self.hiddenImages.count];
    
    for (UIImage *image in self.hiddenImages) {
        
        UIImage *croppedImage = [Utilities imageWithImage:image scaledToWidth:220 + arc4random() % 35];
        if (croppedImage.size.height > self.photoStack.frame.size.height) {
            croppedImage = [Utilities imageWithImage:croppedImage scaledToHeight:self.photoStack.frame.size.height - 10];
        }
        [self.photos addObject:croppedImage];
    }
    
    _photoStack.center = CGPointMake(self.view.center.x, 170);
    _photoStack.dataSource = self;
    _photoStack.delegate = self;
    
    _mediaFocusController = [[URBMediaFocusViewController alloc] init];
	_mediaFocusController.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Image Viewing Screen";
}

- (IBAction)quitButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate dismissViewController];
    }
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
    //self.pageControl.currentPage = index;
}

-(void)photoStackView:(PhotoStackView *)photoStackView didSelectPhotoAtIndex:(NSUInteger)index {
    NSLog(@"selected %d", index);
    [self.mediaFocusController showImage:self.hiddenImages[index] fromView:photoStackView];
}



@end
