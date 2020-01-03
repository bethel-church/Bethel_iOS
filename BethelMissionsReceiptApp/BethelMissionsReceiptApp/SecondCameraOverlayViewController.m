//
//  SecondCameraOverlayViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/17/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "SecondCameraOverlayViewController.h"

@interface SecondCameraOverlayViewController ()
@property (strong, nonatomic) IBOutlet UIButton *retakeButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)onRetake:(id)sender;
- (IBAction)onAddSection:(id)sender;

- (IBAction)onDone:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIView *viewWithThickBorder;

@property (strong, nonatomic) IBOutlet UIView *leftLineView;
@property (strong, nonatomic) IBOutlet UIView *rightLineView;

@end

@implementation SecondCameraOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.helpLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    self.helpLabel.layer.borderWidth = 1.0;
    self.helpLabel.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    [self.viewWithThickBorder sendSubviewToBack:self.imageView];
    [self.viewWithThickBorder bringSubviewToFront:self.helpLabel];
    [self.viewWithThickBorder bringSubviewToFront:self.leftLineView];
    [self.viewWithThickBorder bringSubviewToFront:self.rightLineView];
    [self.view bringSubviewToFront:self.bottomView];
    
    
    self.helpLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12.0];
    self.retakeButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    self.doneButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
  
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onRetake:(id)sender {
    [self.secondOverlayDelegate onRetake];
}

- (IBAction)onAddSection:(id)sender {
    
     [self.secondOverlayDelegate onAddSection];
}
- (IBAction)onDone:(id)sender {
    
     [self.secondOverlayDelegate onDone];
}
@end
