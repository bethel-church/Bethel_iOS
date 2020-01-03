//
//  LoginViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/4/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "LoginViewController.h"
#import "HighlightedButton.h"

@interface LoginViewController ()
{
    double diff;
    NSMutableArray *usersArray;
    NSMutableArray *tripsArray;
}
@property (strong, nonatomic) IBOutlet UILabel *instructionLabel1;
@property (strong, nonatomic) IBOutlet UILabel *instructionLabel2;

@property (strong, nonatomic) IBOutlet UILabel *chooseTripLabel;
@property (strong, nonatomic) IBOutlet UITextField *passcodeLabel;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)onLoginButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *loginBackView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerYConstraint;
- (IBAction)mainViewTapped:(id)sender;
- (IBAction)onChooseTripTap:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) IBOutlet UIImageView *logo;

@property (weak, nonatomic) IBOutlet UILabel *chooseTripTypeLabel;
- (IBAction)onTripTypeLabelTap:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *instruction3;
@property (weak, nonatomic) IBOutlet UILabel *instruction4;
@property (weak, nonatomic) IBOutlet UILabel *instruction5;
@property (weak, nonatomic) IBOutlet UIButton *firstYearMissionsButton;
@property (weak, nonatomic) IBOutlet UIButton *secondYearMissionsButton;
- (IBAction)onFirstYearMissionsBtn:(id)sender;
- (IBAction)onSecondYearMissionsBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIControl *tripTypeBackView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![[defaults valueForKey:@"LOGGED_IN_USERTYPE"]  isEqual: @"-1"] && [defaults valueForKey:@"USER_NAME"]){
        
        HomeViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
        home.userName = [defaults valueForKey:@"USER_NAME"];
        [self.navigationController pushViewController:home animated:NO];
    } else {
        
        
        [[NSUserDefaults standardUserDefaults] setValue:@"-1" forKey:@"LOGGED_IN_USERTYPE"];// -1 for logged out, 0 for member, 1 for leader.
    }
    
    self.instructionLabel1.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15.0];
    self.instructionLabel2.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15.0];
    self.chooseTripLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15.0];
    self.chooseTripTypeLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15.0];
    self.passcodeLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15.0];
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20.0];
    self.instruction3.font = [UIFont fontWithName:@"OpenSans-Bold" size:15.0];
    self.instruction4.font = [UIFont fontWithName:@"OpenSans-Bold" size:15.0];
    self.instruction5.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15.0];
    self.firstYearMissionsButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:20.0];
    self.secondYearMissionsButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:20.0];
    
    self.firstYearMissionsButton.layer.cornerRadius = 5.0;
    self.firstYearMissionsButton.clipsToBounds = YES;
    
    self.secondYearMissionsButton.layer.cornerRadius = 5.0;
    self.secondYearMissionsButton.clipsToBounds = YES;
    
    self.tripTypeBackView.layer.cornerRadius = 5.0;
    self.tripTypeBackView.clipsToBounds = YES;
    
    self.tripTypeBackView.backgroundColor = [UIColor colorWithRed:248/256.0 green:248/256.0 blue:248/256.0 alpha:0.9];
    self.firstYearMissionsButton.backgroundColor = [UIColor colorWithRed:44/256.0 green:76/256.0 blue:83/256.0 alpha:0.8];
     self.secondYearMissionsButton.backgroundColor = [UIColor colorWithRed:44/256.0 green:76/256.0 blue:83/256.0 alpha:0.8];
    
    self.loginBackView.layer.cornerRadius = 5.0;
    self.loginBackView.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.passcodeLabel];
    
    [self.view bringSubviewToFront:self.loginBackView];
    [self.view bringSubviewToFront:self.logo];
    [self animateImages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidLogout) name:@"APPLOGGEDOUT" object:nil];
    
    if([self.chooseTripTypeLabel.text isEqualToString:@""])
    {
        self.loginBackView.alpha = 0.0;
        self.tripTypeBackView.alpha = 1.0;
        [self.view bringSubviewToFront:self.tripTypeBackView];
        [self.view bringSubviewToFront:self.logo];
        
    }
}

-(void) appDidLogout
{
    self.chooseTripLabel.text = @"choose trip";
    self.chooseTripLabel.textColor = [UIColor lightGrayColor];
    self.passcodeLabel.text = @"";
    [[NSUserDefaults standardUserDefaults] setValue:@"-1" forKey:@"LOGGED_IN_USERTYPE"];// -1 for logged out, 0 for member, 1 for leader.
}

- (void)animateImages
{
    static int count = 0;
    NSArray *animationImages = @[[UIImage imageNamed:@"2"], [UIImage imageNamed:@"3"],[UIImage imageNamed:@"4"],[UIImage imageNamed:@"5"],[UIImage imageNamed:@"6"],[UIImage imageNamed:@"1"]];
    UIImage *image = [animationImages objectAtIndex:(count % [animationImages count])];
    
    [UIView transitionWithView:self.bgImageView
                      duration:4.0f // animation duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.bgImageView.image = image; // change to other image
                    } completion:^(BOOL finished) {
                        [self animateImages]; // once finished, repeat again
                        count++; // this is to keep the reference of which image should be loaded next
                    }];
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

-(void)keyboardWillShow:(NSNotification*)notif
{
    CGRect keyboardRect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect windowRect = [self.view.window convertRect:keyboardRect fromWindow:nil];
    CGRect keyboardViewRect = [self.view  convertRect:windowRect fromView:nil];
    
    diff = (self.loginBackView.frame.origin.y + self.loginBackView.frame.size.height) - keyboardViewRect.origin.y;
   
    
    if (diff > 0) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.centerYConstraint.constant = self.centerYConstraint.constant + diff + 20;
            [self.view layoutIfNeeded];
        }];
    }
}

-(void)keyboardWillHide:(NSNotification*)notif
{
    [self.view updateConstraintsIfNeeded];
    if (diff > 0) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.centerYConstraint.constant = self.centerYConstraint.constant -  diff - 20;
            [self.view layoutIfNeeded];
            diff = 0.0;
        }];
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![self.chooseTripLabel.text isEqualToString:@"choose trip"] && self.passcodeLabel.text.length > 0)
    {
        [self.loginButton setEnabled:YES];
    }
    else
    {
        [self.loginButton setEnabled:NO];
    }
    
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)onLoginButton:(id)sender
{
    [self.view endEditing:YES];
    if ([Internet isInternetAvailable])
    {
        NSDictionary *tripDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_TRIP"];
        [[WebCalls sharedWebCalls] login:[tripDict valueForKey:@"id"] passcode:self.passcodeLabel.text caller:self];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    
}
- (IBAction)mainViewTapped:(id)sender {
    
    [self.view endEditing:YES];
}

- (IBAction)onChooseTripTap:(id)sender {
     [self.view endEditing:YES];
    
    
    if ([Internet isInternetAvailable])
    {
        [[WebCalls sharedWebCalls] getTripList:self.chooseTripTypeLabel.text caller:self];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    
}
-(void)selectedTrip:(NSString *)trip
{
    [self.chooseTripLabel setText:trip];
    [self.chooseTripLabel setTextColor: [UIColor blackColor]];
    
    if (![self.chooseTripLabel.text isEqualToString:@"choose trip"] && self.passcodeLabel.text.length > 0)
    {
        [self.loginButton setEnabled:YES];
    }
    else
    {
        [self.loginButton setEnabled:NO];
    }
}

-(void)textFieldTextDidChange:(NSNotification*)notif
{
    UITextField * tf = notif.object;
    ;
    if (tf.text.length < 3)
    {
         [self.loginButton setEnabled:NO];
    }
    else
    {
        if (![self.chooseTripLabel.text isEqualToString:@"choose trip"])
        {
            [self.loginButton setEnabled:YES];
        }
    }
   
    
}

-(void)didGetWebResponse:(id)response forWebCall:(NSString *)webCall
{
    if (response)
    {
        if ([webCall isEqualToString:@"login"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
                
                NSDictionary * tripsDict = [response valueForKey:@"trips"];
                usersArray = [tripsDict valueForKey:@"User"];
                if ([usersArray count] > 0)
                {
                        SelectTripAndNameViewController *st = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectTrip"];
                        st.delegate = self;
                        st.mode = @"Member_Name";
                        st.usersArray = usersArray;
                        [self.navigationController pushViewController:st animated:YES];
                    
                    // clean any stored web service responses for offline mode
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"trip_currencies"];
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"trip_budget"];
                   // [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"uploaded_receipts"];
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"isArchived"];
                }
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Invalid trip/passcode combination. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        }
        else if ([webCall isEqualToString:@"get_trip_list"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
                NSDictionary * tripsDict = [response valueForKey:@"trips"];
                tripsArray = [tripsDict valueForKey:@"Trip"];
                if([tripsArray count] > 0)
                {
                    SelectTripAndNameViewController *st = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectTrip"];
                    st.delegate = self;
                    st.mode = @"Trip_Name";
                    st.tripsArray = tripsArray;
                    [self.navigationController pushViewController:st animated:YES];
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle:@"No Trips!" message:@"No trips have been added." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
                
            }
        }
       
    }
}
- (IBAction)onTripTypeLabelTap:(id)sender {
    
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.5 animations:^{
        
        self.loginBackView.alpha = 0.0;
        self.tripTypeBackView.alpha = 1.0;
        [self.view bringSubviewToFront:self.tripTypeBackView];
        
    }];
    
}
- (IBAction)onFirstYearMissionsBtn:(id)sender {
    
    HighlightedButton * btn = (HighlightedButton*)sender;
    
    self.chooseTripTypeLabel.text = @"Mission Trips";
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.tripTypeBackView.alpha = 0.0;
        self.loginBackView.alpha = 0.9;
        
        [self.view bringSubviewToFront:self.loginBackView];
        [self.chooseTripTypeLabel setTextColor: [UIColor blackColor]];
        
    } completion:^(BOOL finished) {
        
        [btn setHighlighted:NO];
        [btn setSelected:NO];
    }];
    
}

- (IBAction)onSecondYearMissionsBtn:(id)sender {
    
    HighlightedButton * btn = (HighlightedButton*)sender;
    self.chooseTripTypeLabel.text = @"2nd Year Travel";
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.tripTypeBackView.alpha = 0.0;
        self.loginBackView.alpha = 0.9;
        [self.view bringSubviewToFront:self.loginBackView];
        [self.chooseTripTypeLabel setTextColor: [UIColor blackColor]];
        
    } completion:^(BOOL finished) {
        [btn setHighlighted:NO];
        [btn setSelected:NO];
    }];
}
@end
