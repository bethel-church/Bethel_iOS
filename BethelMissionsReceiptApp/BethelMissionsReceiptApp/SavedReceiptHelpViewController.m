//
//  SavedReceiptHelpViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 23/05/16.
//  Copyright © 2016 Calico. All rights reserved.
//

#import "SavedReceiptHelpViewController.h"

@interface SavedReceiptHelpViewController ()

- (IBAction)onGotItButton:(id)sender;

- (IBAction)onDoNotShow:(id)sender;

@end

@implementation SavedReceiptHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   
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

- (IBAction)onGotItButton:(id)sender {
    
    [self.savedHelpOverlayDelegate onGotSavedHelpButton];
}

- (IBAction)onDoNotShow:(id)sender {
    
    UIButton *btn = (UIButton*)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([btn isSelected])
    {
        [btn setSelected:NO];
        [defaults setValue:@"YES" forKey:@"SHOW_HELP_SAVED"];
    }
    else
    {
        [btn setSelected:YES];
        [defaults setValue:@"NO" forKey:@"SHOW_HELP_SAVED"];
    }
}
@end
