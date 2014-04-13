//
//  SpotsTableViewController.m
//  MySpots
//
//  Created by FlyinGeek on 4/13/14.
//  Copyright (c) 2014 CodeStrikers. All rights reserved.
//

#import "Utilities.h"
#import "SpotsTableViewController.h"
#import "MHNatGeoViewControllerTransition.h"
#import "ANBlurredTableView.h"
#import "UIViewController+CWPopup.h"
#import "JDStatusBarNotification.h"
#import "SpotsManager.h"

#import "Spot.h"
#import "TextSpot.h"
#import "ImageSpot.h"
#import "AudioSpot.h"

#import "TextViewController.h"
#import "ImageViewController.h"
#import "AudioViewController.h"

@interface SpotsTableViewController () <UITableViewDataSource, UITableViewDelegate, AudioViewControllerDelegate, ImageViewControllerDelegate, TextViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet ANBlurredTableView *tableView;

@end

@implementation SpotsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[Utilities addBackgroundImageToView:self.view withImageName:@"bg_1.jpg"];
    self.useBlurForPopup = YES;
    
    // Stuff for populating our tableView.
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    // Our default color is clear. We want a nice dark gray.
    [_tableView setBlurTintColor:[UIColor colorWithWhite:0.11 alpha:0.5]];
    
    // We want to animate our background's alpha, so switch this to yes.
    [_tableView setAnimateTintAlpha:YES];
    [_tableView setStartTintAlpha:0.35f];
    [_tableView setEndTintAlpha:0.75f];
    
    // Our background image. After this point, ANBlurredTableView takes over and renders the frames.
    [_tableView setBackgroundImage:[UIImage imageNamed:@"bg_1.jpg"]];
    
    // Offset our header for ~style~ reasons.
    [_tableView setContentInset:UIEdgeInsetsMake(0.0, 0, 0, 0)];
}

- (IBAction)backButtonPressed:(id)sender {

    [self.tabBarController dismissNatGeoViewController];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [SpotsManager sharedManager].spots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"spotCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"spotCell"];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    Spot *spot = [SpotsManager sharedManager].spots[indexPath.row];
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:spot.name
     attributes:@
     {
     NSFontAttributeName: [UIFont fontWithName:@"OpenSans" size:17.f]
     }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){320 - 40, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    
    
    if (![cell viewWithTag:1]) {
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, cell.frame.size.width - 40, rect.size.height + 25)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"OpenSans" size:17.f];
        titleLabel.tag = 1;
        titleLabel.numberOfLines = 10;
        [cell addSubview:titleLabel];
        
        UILabel *createDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, rect.size.height + 15, cell.frame.size.width - 40, 20)];
        createDateLabel.textColor = [UIColor whiteColor];
        createDateLabel.font = [UIFont fontWithName:@"OpenSans" size:12.f];
        createDateLabel.tag = 2;
        [cell addSubview:createDateLabel];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd yyyy hh:ss"];
    
    [(UILabel *)[cell viewWithTag:1] setText:spot.name];
    [(UILabel *)[cell viewWithTag:2] setText:[@"Created on " stringByAppendingString:[formatter stringFromDate:spot.createDate]]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Spot *spot = [SpotsManager sharedManager].spots[indexPath.row];
    
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:spot.name
     attributes:@
     {
     NSFontAttributeName: [UIFont fontWithName:@"OpenSans" size:17.f]
     }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){320 - 40, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    return rect.size.height + 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Spot *targetSpot = [SpotsManager sharedManager].spots[indexPath.row];
    
    if ([targetSpot isKindOfClass:[TextSpot class]]) {
        
        TextViewController *textVC = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
        [(TextSpot *)targetSpot decryptHiddenTextWithCompletionBlock:^(NSString *hiddenText){
            textVC.hiddenText = hiddenText;
        }];
        textVC.spot = targetSpot;
        textVC.delegate = self;
        [self presentPopupViewController:textVC animated:YES completion:nil];
        
    } else if ([targetSpot isKindOfClass:[ImageSpot class]]) {
        
        [JDStatusBarNotification showWithStatus:@"Decrypting..." styleName:JDStatusBarStyleError];
        
        [(ImageSpot *)targetSpot decryptHiddenImagesWithCompletionBlock:^(NSArray *images){
            
            ImageViewController *imageVC = [[ImageViewController alloc] initWithNibName:@"ImageViewController" bundle:nil];
            imageVC.hiddenImages = images;
            imageVC.spot = targetSpot;
            imageVC.delegate = self;
            [self presentPopupViewController:imageVC animated:YES completion:nil];
            [JDStatusBarNotification showWithStatus:@"Decryption succeeded!" dismissAfter:1.0f styleName:JDStatusBarStyleSuccess];
        }];
    } else if ([targetSpot isKindOfClass:[AudioSpot class]]) {
        
        [JDStatusBarNotification showWithStatus:@"Decrypting..." styleName:JDStatusBarStyleError];
        
        [(AudioSpot *)targetSpot decryptHiddenAudioWithCompletionBlock:^(NSData *hiddenAudioData){
            
            AudioViewController *audioVC = [[AudioViewController alloc] initWithNibName:@"AudioViewController" bundle:nil];
            audioVC.hiddenAudioData = hiddenAudioData;
            audioVC.spot = targetSpot;
            audioVC.delegate = self;
            [self presentPopupViewController:audioVC animated:YES completion:nil];
            [JDStatusBarNotification showWithStatus:@"Decryption succeeded!" dismissAfter:1.0f styleName:JDStatusBarStyleSuccess];
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        Spot *delSpot = [SpotsManager sharedManager].spots[indexPath.row];
        [[SpotsManager sharedManager] removeSpotByName:delSpot.name];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SpotsDataChanged" object:nil];
    }
}

-(void)dismissViewController
{
    [self dismissPopupViewControllerAnimated:YES completion:nil];
}

@end
