//
//  AddBudgetAndCurrenciesViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/7/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "AddBudgetAndCurrenciesViewController.h"
#import "WebCalls.h"
#import "HomeViewController.h"
#import "Internet.h"
@interface AddBudgetAndCurrenciesViewController ()
{
    double diff;
}

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) IBOutlet UILabel *firstQuestionLabel;
@property (strong, nonatomic) IBOutlet UILabel *dontWorryLabel;
@property (strong, nonatomic) IBOutlet UITextField *budgetTextField;
@property (strong, nonatomic) IBOutlet UILabel *secondQuestionLabel;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)onDoneButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *selectCurrenciesButton;
- (IBAction)onSelectCurrencies:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *currenciesLabel;
@property (strong,nonatomic) NSMutableArray *selectedCurrencies;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *firstQuestionLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *dontWorryLabelTopConstraint;
@end

@implementation AddBudgetAndCurrenciesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *boldText = @"Hey, ";
    NSString *normalText = [NSString stringWithFormat:@"%@!",[[self.userName componentsSeparatedByString:@" "] objectAtIndex:0]];
    
    NSString *fullString = [NSString stringWithFormat:@"%@%@", boldText,normalText];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fullString];
    
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:14.0]} range:[fullString rangeOfString:boldText]];
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Bold" size:14.0]} range:[fullString rangeOfString:normalText]];
    self.nameLabel.attributedText = attributedString;
    
    boldText = @"Some quick questions";
    normalText = @"about your trip";
    
    fullString = [NSString stringWithFormat:@"%@ %@", boldText,normalText];
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:fullString];
    
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Bold" size:14.0]} range:[fullString rangeOfString:boldText]];
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:14.0]} range:[fullString rangeOfString:normalText]];
    self.firstLabel.attributedText = attributedString;
    
    self.secondLabel.font = [UIFont fontWithName:@"OpenSans" size:14.0];
    
    self.firstQuestionLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    self.secondQuestionLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    self.budgetTextField.font = [UIFont fontWithName:@"OpenSans-Semibold" size:18];
    self.dontWorryLabel.font = [UIFont fontWithName:@"OpenSans" size:13];
    self.doneButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20.0];
    self.budgetTextField.delegate = self;
    
    self.currenciesLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:16];
    self.selectCurrenciesButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:19];
    
    self.selectedCurrencies = [[NSMutableArray alloc] init];
    
    [self setCurrencies:self.selectedCurrencies];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(doneButton:)];
    
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexibleSpace,doneButton, nil]];
    self.budgetTextField.inputAccessoryView = keyboardDoneButtonView;
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)keyboardWillShow:(NSNotification *)note {
  
    CGRect keyboardRect = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect windowRect = [self.view.window convertRect:keyboardRect fromWindow:nil];
    CGRect keyboardViewRect = [self.view  convertRect:windowRect fromView:nil];
    
    diff = (self.budgetTextField.frame.origin.y + self.budgetTextField.frame.size.height) - keyboardViewRect.origin.y;
    
    
    if (diff > 0) {
        
        
        [UIView animateWithDuration:0.5 animations:^{
            
//            self.view.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y - diff - 20,self.view.frame.size.width,self.view.frame.size.height);
            self.firstQuestionLabelTopConstraint.constant -= (diff + 20);
            self.dontWorryLabelTopConstraint.constant -= (diff + 20);
            [self.view sendSubviewToBack:self.firstQuestionLabel];
            [self.view sendSubviewToBack:self.dontWorryLabel];
            [self.view layoutIfNeeded];
        }];
    }
    
   
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] lastObject];
    
//    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    //doneButton.frame = CGRectMake(0, tempWindow.frame.size.height -53 , 106, 53);
//    doneButton.frame = CGRectMake(0, tempWindow.frame.size.height , 106, 54);
//    doneButton.adjustsImageWhenHighlighted = NO;
//    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
//    [doneButton setBackgroundColor:[UIColor colorWithRed:68/256.0 green:88/256.0 blue:92/256.0 alpha:1.0]];
//    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [doneButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:20]];
//    [doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
//    doneButton.tag = 1007;
//    [tempWindow addSubview:doneButton];
//  
//    [UIView animateWithDuration:0.4 animations:^{
//       doneButton.frame = CGRectMake(0, tempWindow.frame.size.height -54 , 106, 54);
//    }];
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

- (void)keyboardWillHide:(NSNotification *)note
{
//    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] lastObject];
//    
//    for (UIButton * btn in tempWindow.subviews) {
//        if (btn.tag == 1007)
//        {
//            [btn removeFromSuperview];
//        }
//    }
    
    
    if (diff > 0) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.firstQuestionLabelTopConstraint.constant += (diff + 20);
            self.dontWorryLabelTopConstraint.constant += (diff + 20);
            [self.view layoutIfNeeded];
        }];
    }
    
   
    
}

-(void)doneButton:(id)sender
{
    if (self.budgetTextField.text.length > 0)
    {
        [self.doneButton setEnabled:YES];
    }
    else
    {
        [self.doneButton setEnabled:NO];
    }
    
    [self.budgetTextField resignFirstResponder];
}

-(void) setCurrencies:(NSMutableArray*)currencies
{
    int counter = 0;
    NSString *labelTextString = @"";
    for (NSString *currency in currencies)
    {
        if (counter == 0)
        {
            labelTextString = [labelTextString stringByAppendingString:[[WebCalls currencyFullNamesDictionary] objectForKey:currency]];
        }
        else
        {
            labelTextString = [labelTextString stringByAppendingString:[NSString stringWithFormat:@", %@",[[WebCalls currencyFullNamesDictionary] objectForKey:currency]]];
        }
        counter++;
    }
    
    self.currenciesLabel.text = labelTextString;
    
    if (self.currenciesLabel.text.length > 0 )
    {
        [self.selectCurrenciesButton setTitle:@"Edit Currencies" forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:currencies forKey:@"Selected_Currencies"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [self.selectCurrenciesButton setTitle:@"Select Currencies" forState:UIControlStateNormal];
    }
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


- (IBAction)onDoneButton:(id)sender
{
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

- (IBAction)onSelectCurrencies:(id)sender
{
    SelectCurrenciesViewController *sc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCurrencies"];
    sc.selectedCurrencies = self.selectedCurrencies;
    sc.delegate = self;
    sc.animatedPop = NO;
    [self.navigationController pushViewController:sc animated:NO];
}

-(void)didGetWebResponse:(id)response forWebCall:(NSString *)webCall
{
    if (response)
    {
        if ([webCall isEqualToString:@"set_trip_budget"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
                [self setCurrencies:self.selectedCurrencies];
                HomeViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
                home.userName = self.userName;
                [self.navigationController pushViewController:home animated:YES];
            }
            
        }
    }
}
@end
