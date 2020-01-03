//
//  ArchivedTripViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 10/27/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "ArchivedTripViewController.h"

@interface ArchivedTripViewController ()

- (IBAction)onLogoutButton:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
- (IBAction)onEmailButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *emailButton;

@end

@implementation ArchivedTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *fullString = @"This trip has been Archived. if you feel that more receipts need to entered for this trip, email";
    
   NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fullString];
    
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:16.0]} range:[fullString rangeOfString:@"This trip has been Archived. if you feel that more receipts need to entered for this trip, email"]];
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Bold" size:16.0]} range:[fullString rangeOfString:@"Archived"]];
    
    self.textLabel.attributedText = attributedString;
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

- (IBAction)onLogoutButton:(id)sender {
    
    [self.delegate logout];
}
- (IBAction)onEmailButton:(id)sender {
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setMessageBody:@"Here is some main text in the email!" isHTML:NO];
        [mail setToRecipients:@[@"missions@ibethel.org"]];
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
       [[[UIAlertView alloc] initWithTitle:@"No Email Account!" message:@"Please configure an email account on your iPhone." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
