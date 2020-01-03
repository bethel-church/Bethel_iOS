//
//  FirstCameraOverlayViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/17/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "FirstCameraOverlayViewController.h"

@interface FirstCameraOverlayViewController ()
@property (strong, nonatomic) IBOutlet UIView *viewWithThickBorder;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *helpButton;
- (IBAction)onCancel:(id)sender;
- (IBAction)onHelp:(id)sender;
- (IBAction)onTakePicture:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet UILabel *sectionNumberLabel;
@property (strong, nonatomic) IBOutlet UIImageView *previousReceiptImagView;
@property (strong, nonatomic) IBOutlet UIView *leftLineView;
@property (strong, nonatomic) IBOutlet UIView *rightLineView;

@end

@implementation FirstCameraOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
    self.viewWithThickBorder.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
    
    self.helpLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    self.helpLabel.layer.borderWidth = 1.0;
    self.helpLabel.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [self.viewWithThickBorder sendSubviewToBack:self.helpLabel];
    
    [self.view bringSubviewToFront:self.bottomView];
    
    self.helpLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12.0];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    self.helpButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
   
    self.previousReceiptView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.sectionNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 77, 21, 21)];
    self.sectionNumberLabel.textColor = [UIColor whiteColor];
    self.sectionNumberLabel.text = @"2";
    self.sectionNumberLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.sectionNumberLabel.textAlignment = NSTextAlignmentCenter;
    
    self.previousReceiptImagView = [[UIImageView alloc] initWithFrame:CGRectMake(22, 0, self.view.frame.size.width - 44, 100)];
    self.previousReceiptImagView.contentMode = UIViewContentModeScaleAspectFill;
    self.previousReceiptImagView.clipsToBounds = YES;
    
    
    
    [self.previousReceiptView addSubview:self.previousReceiptImagView];
    [self.previousReceiptView addSubview:self.sectionNumberLabel];
    
    [self.view addSubview:self.previousReceiptView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showPreviousReceiptView:(UIImage*)previousReceiptImage sectionNumber:(NSInteger)section
{
    
     [self.view bringSubviewToFront:self.previousReceiptImagView];
    //set dashed line
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//    [shapeLayer setBounds:self.previousReceiptView.bounds];
//    [shapeLayer setPosition:self.center];
    [shapeLayer setFrame:CGRectMake(0, self.previousReceiptView.frame.size.height - 1.5, self.view.frame.size.width, 3)];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
    [shapeLayer setLineWidth:3.0f];
    [shapeLayer setLineJoin:kCALineCapSquare];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:5],
      [NSNumber numberWithInt:5],nil]];
    
    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, self.view.frame.size.width,0);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [[self.previousReceiptView layer] addSublayer:shapeLayer];
    
    //set previous receipt image
    
    CGRect contentFrame = CGRectMake(0, 1 -  (100/(self.view.frame.size.height - 50)), 1,100/(self.view.frame.size.height - 50));
    self.previousReceiptImagView.layer.contentsRect = contentFrame;
    
    self.previousReceiptImagView.image = previousReceiptImage;
    self.sectionNumberLabel.text = [NSString stringWithFormat:@"%d",section];
    
    
    
    [self.viewWithThickBorder bringSubviewToFront:self.leftLineView];
    [self.viewWithThickBorder bringSubviewToFront:self.rightLineView];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onCancel:(id)sender {
    
    [self.firstOverlayDelegate onCancel];
}

- (IBAction)onHelp:(id)sender {
    [self.firstOverlayDelegate onHelp];
}

- (IBAction)onTakePicture:(id)sender {
    [self.firstOverlayDelegate takePicutre];
}
@end
