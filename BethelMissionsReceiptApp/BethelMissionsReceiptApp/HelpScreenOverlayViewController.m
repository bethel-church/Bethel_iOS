//
//  HelpScreenOverlayViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 10/6/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "HelpScreenOverlayViewController.h"

@interface HelpScreenOverlayViewController ()
- (IBAction)checkButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)onCancelButton:(id)sender;
- (IBAction)onGotIt:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *checkBtn;

@end

@implementation HelpScreenOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
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

- (IBAction)checkButton:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([btn isSelected])
    {
        [btn setSelected:NO];
        [defaults setValue:@"YES" forKey:@"SHOW_HELP"];
    }
    else
    {
         [btn setSelected:YES];
        [defaults setValue:@"NO" forKey:@"SHOW_HELP"];
    }
}
- (IBAction)onCancelButton:(id)sender
{
    [self.helpOverlayDelegate onCancel];
}

- (IBAction)onGotIt:(id)sender {
    
    [self.helpOverlayDelegate onGotIt];
}
-(void)showCheckButton:(BOOL)show
{
    [self.checkBtn setHidden:!show];
}
@end
