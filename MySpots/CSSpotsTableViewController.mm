//
//  CSSpotsTableViewController.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSUtilities.h"
#import "CSSpotsTableViewController.h"

@interface CSSpotsTableViewController ()

@property (nonatomic, strong) NSMutableArray *spots;

@end

@implementation CSSpotsTableViewController

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
    
    // get spots data from disk or web
    [self getData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exitButtonPressed:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)getData
{
    CSDataHandler *handler = [CSDataHandler sharedInstance];
    handler.delegate = self;
    
    /*
    if (!handler.spotsLoaded) {
        self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.HUD.delegate = self;
        self.HUD.labelText = @"Loading";
        self.HUD.detailsLabelText = @"updating data";
        self.HUD.color = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.80];
        self.HUD.square = YES;
    }
     */
    [handler getSpots];
}


#pragma -- protocols ***********************************************

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.spots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSSpotCell *cell = [tableView dequeueReusableCellWithIdentifier:@"spotCell"];
    
    CSSpot *spot = [self.spots objectAtIndex:indexPath.row];
    cell.spotName.text = [NSString stringWithFormat:@"%@", spot.name];
    cell.tagColor = [CSUtilities colorFromHexString:spot.tagColor];

    cell.tagView.layer.cornerRadius= 20.0/2;
    cell.tagView.clipsToBounds = YES;
    cell.tagView.backgroundColor = [CSUtilities colorFromHexString:spot.tagColor];
    //[CSUtilities addShadowToUIImageView:cell.viewForBaselineLayout];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [EAGLContext setCurrentContext:nil];
    CSGeoARViewController * VC = [[CSGeoARViewController alloc] initWithNibName:@"CSGeoAR" bundle:nil];
    VC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    VC.spot = [self.spots objectAtIndex:self.spotsTable.indexPathForSelectedRow.row];
    
    [self presentViewController:VC animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma HEWebDataHandler protocal

- (void)spotsLoaded:(NSMutableArray *)spots
{
    [CSDataHandler writeSpotsToDisk:spots];
    
    NSMutableArray *newSpots = [NSMutableArray arrayWithArray:[CSDataHandler loadSpotsFromDisk]];
    
    self.spots = newSpots;
    [self.spotsTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	//[self.HUD hide:YES];

}

-(void)connectionFailed
{
    //[self.HUD hide:YES];
    
    /*
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeCustomView;
    [hud setMode:MBProgressHUDModeText];
	hud.labelText = @"Connection Failed!";
	hud.margin = 10.f;
	hud.yOffset = 150.f;
    hud.color = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.80];
	hud.removeFromSuperViewOnHide = YES;
	
	[hud hide:YES afterDelay:1.5f];
     */
}

@end
