//
//  SettingsContainerViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 23/05/16.
//  Copyright © 2016 Calico. All rights reserved.
//

#import "SettingsContainerViewController.h"
#import "SettingsViewController.h"
@interface SettingsContainerViewController ()
{
    NSString *budget;
    SettingsViewController *sts;
}
@property (weak, nonatomic) IBOutlet UILabel *dollarLabel;
@property (weak, nonatomic) IBOutlet UITextField *budgetTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveBudgetButton;
- (IBAction)onSaveBudgetButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *budgetAmountLabel;
@property (weak, nonatomic) IBOutlet UIView *borderLineView;


@end

@implementation SettingsContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    self.budgetTextField.font =  [UIFont fontWithName:@"OpenSans-Regular" size:20];
    self.dollarLabel.font = [UIFont fontWithName:@"OpenSans-Regular" size:20];
    self.budgetAmountLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20];
    self.borderLineView.backgroundColor = [UIColor colorWithRed:237/256.0 green:237/256.0 blue:237/256.0 alpha:1.0];
    //Read budget dict from defaults
    
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] valueForKey:@"trip_budget"] ;
    
    NSDictionary *budgetDict = [dict valueForKey:@"trip_details"];
    if (budgetDict)
    {
        budget = [NSString stringWithFormat:@"%.2f",[[budgetDict valueForKey:@"budget"] doubleValue]];
        self.budgetTextField.text = budget;
    }
    
    //Done tool bar for keyboard
//    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
//    [keyboardDoneButtonView sizeToFit];
//    
//    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
//                                                                   style:UIBarButtonItemStyleBordered target:self
//                                                                  action:@selector(doneButton:)];
//    
//    
//    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexibleSpace,doneButton, nil]];
//    self.budgetTextField.inputAccessoryView = keyboardDoneButtonView;
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    sts = [self.storyboard instantiateViewControllerWithIdentifier:@"Settings"];
    
    sts.homeViewController = self.homeViewController;
    
    [self addChildViewController:sts];
    
    sts.view.frame = CGRectMake(self.view.frame.origin.x, self.saveBudgetButton.frame.origin.y + self.saveBudgetButton.frame.size.height + 1, self.view.frame.size.width, self.view.frame.size.height - (self.saveBudgetButton.frame.origin.y + self.saveBudgetButton.frame.size.height + 1));
    
    [self.view addSubview:sts.view];
    
    [sts didMoveToParentViewController:self];
    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    sts.view.frame = CGRectMake(self.view.frame.origin.x, self.saveBudgetButton.frame.origin.y + self.saveBudgetButton.frame.size.height + 1, self.view.frame.size.width, self.view.frame.size.height - (self.saveBudgetButton.frame.origin.y + self.saveBudgetButton.frame.size.height + 1));
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
   
    
    
    NSString *checkString = @"0123456789.";
    
    if (![checkString containsString:string])
    {
        return YES;
    }
    
    if (textField.text.length < 9)
    {
        if ([textField.text containsString:@"."])
        {
            NSArray *comps = [textField.text componentsSeparatedByString:@"."];
            if (((NSString*)[comps objectAtIndex:1]).length < 2)
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
        return YES;
    }
    
    return NO;
}


-(void)doneButton:(id)sender
{
    if (self.budgetTextField.text.length > 0)
    {
        [self.saveBudgetButton setEnabled:YES];
    }
    else
    {
        [self.saveBudgetButton setEnabled:NO];
    }
   [self.budgetTextField resignFirstResponder];
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

- (IBAction)onSaveBudgetButton:(id)sender {
    
    if (self.budgetTextField.text.length > 0)
    {
        [self.budgetTextField resignFirstResponder];
        
        if ([Internet isInternetAvailable])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
            NSDictionary *tripDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_TRIP"];
            [[WebCalls sharedWebCalls] setTripBudget:[tripDict valueForKey:@"id"] tripBudget:self.budgetTextField.text caller:self];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
    
}

-(void)didGetWebResponse:(id)response forWebCall:(NSString *)webCall{
    
    if (response)
    {
        if ([webCall isEqualToString:@"set_trip_budget"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
              // Show "budget saved" custom popup here.
            }
            
        }
    }
    
}
@end
