//
//  HomeViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/9/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "HomeViewController.h"
#import "AddReceiptViewController.h"
#import "SettingsViewController.h"
#import "ViewReceiptsTableViewController.h"
#import "Internet.h"
#import "ReceiptsContainerViewController.h"
#import "SettingsContainerViewController.h"
#import "MembersListViewController.h"


@interface HomeViewController ()
{
    HelpScreenOverlayViewController *help;
    NSString * homeScreenAction;
    
    
    NSInteger countSavedReceipts;
    
}
- (IBAction)onSettingsButton:(id)sender;
- (IBAction)onLogoutButton:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *tripNameLabel;
- (IBAction)onAddReceiptButton:(id)sender;
- (IBAction)onViewRecieptsButton:(id)sender;

- (IBAction)onViewMembersButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *viewMembersButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addReceiptPlacementConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNamePlacementConstraint;

@property (strong, nonatomic) IBOutlet UILabel *budgetLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalSpentLabel;
@property (strong, nonatomic) IBOutlet UILabel *remainingLabel;
@property (strong, nonatomic) IBOutlet UILabel *budgetValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalSpentValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *remainingValueLabel;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UIView *budgetView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.userNameLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:22.0];
    self.tripNameLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15.0];
    
    self.budgetLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12];
    self.totalSpentLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12];
    self.remainingLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12];
    
    self.budgetValueLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:17];
    self.totalSpentValueLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:17];
    self.remainingValueLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:17];
    
    self.userNameLabel.text = self.userName;
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *tripDict = [defaults objectForKey:@"SELECTED_TRIP"];
    self.tripNameLabel.text = [tripDict valueForKey:@"name"];
    
    if ([[defaults valueForKey:@"LOGGED_IN_USERTYPE"] isEqualToString:@"0"])
    {
        [self.settingsButton setHidden:YES];
        
        self.budgetLabel.hidden = YES;
        self.remainingLabel.hidden = YES;
        self.viewMembersButton.hidden = YES;
    }
    
    
  
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    if ([Internet isInternetAvailable])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *userType = [defaults valueForKey:@"LOGGED_IN_USERTYPE"];
        
        homeScreenAction = @"View Will Appear";
        [[WebCalls sharedWebCalls] isTripArchived:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
       
        if ([userType integerValue] > 0)
        {
            [[WebCalls sharedWebCalls] getTripBudget:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
        }
        else{
            
            [[WebCalls sharedWebCalls] getStudentBudgetDetails:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] userName:self.userName caller:self];
        }
      
        [[WebCalls sharedWebCalls] getTripCurrencies:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
       
    }
    else
    {
       // [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults valueForKey:@"LOGGED_IN_USERTYPE"] isEqualToString:@"0"]){
        
        self.addReceiptPlacementConstraint.constant = 30;
    }else{
        self.addReceiptPlacementConstraint.constant = 15;
    }
    
    if([[UIScreen mainScreen] bounds].size.height >= 568)
    {
        self.userNamePlacementConstraint.constant = 20.0;
    }
    else{
        self.userNamePlacementConstraint.constant = 5.0;
    }
    
    
   
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onSettingsButton:(id)sender {
    
    homeScreenAction = @"Settings";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[WebCalls sharedWebCalls] isTripArchived:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
}

- (void)logout //This is a delegate method from LogoutDelegate declared in  ArchivedTripViewController.h
{
    //Simply delete any saved receipts and logout. Trip is archived so user does not have option to delete "Saved for Later" receipts. So there is no use showing him the logout prompt.
    
    NSManagedObjectContext* managedContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Receipts"];
    NSArray * managedObjects = [managedContext executeFetchRequest:fetchRequest error:nil];
    countSavedReceipts = managedObjects.count;
    
    if (countSavedReceipts > 0){
        
        for (NSManagedObject *obj in managedObjects){
            
            [managedContext deleteObject:obj];
        }
        
        NSError *error = nil;
        if (![managedContext save:&error]) {
            NSLog(@"Could not save context after deleting saved receipts on logout! %@ %@", error, [error localizedDescription]);
            return;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"Selected_Currencies"];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APPLOGGEDOUT" object:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onLogoutButton:(id)sender {
    
    NSManagedObjectContext* managedContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Receipts"];
    NSArray * managedObjects = [managedContext executeFetchRequest:fetchRequest error:nil];
    countSavedReceipts = managedObjects.count;
    
    if (countSavedReceipts > 0){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You have receipts for this trip that are waiting to be uploaded. Logging out from the app will automatically delete any Saved for Later receipts. Would you like to upload them now?" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Logout", nil];
        [alert show];
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
   
}


- (IBAction)onAddReceiptButton:(id)sender {
    
     homeScreenAction = @"Add Receipt";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[WebCalls sharedWebCalls] isTripArchived:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
    
    //[self.navigationController pushViewController:ar animated:YES];
}

- (IBAction)onViewRecieptsButton:(id)sender {
    
    homeScreenAction = @"View Receipts";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[WebCalls sharedWebCalls] isTripArchived:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
}

- (IBAction)onViewMembersButton:(id)sender {
    
    homeScreenAction = @"View Members";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[WebCalls sharedWebCalls] isTripArchived:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    
    if (buttonIndex == 1)
    {
        NSManagedObjectContext* managedContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Receipts"];
        NSArray * managedObjects = [managedContext executeFetchRequest:fetchRequest error:nil];
        countSavedReceipts = managedObjects.count;
        
        if (countSavedReceipts > 0){
            
            for (NSManagedObject *obj in managedObjects){
                
                [managedContext deleteObject:obj];
            }
            
            NSError *error = nil;
            if (![managedContext save:&error]) {
                NSLog(@"Could not save context after deleting saved receipts on logout! %@ %@", error, [error localizedDescription]);
                return;
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"Selected_Currencies"];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.navigationController.navigationBarHidden = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"APPLOGGEDOUT" object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}



-(void)didGetWebResponse:(id)response forWebCall:(NSString *)webCall
{
    if (response)
    {
        if ([webCall isEqualToString:@"get_trip_currencies"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
                NSDictionary * tripsDict = [response valueForKey:@"trips"];
                if (tripsDict)
                {
                    NSArray * currencies = [tripsDict valueForKey:@"Currency"];
                    if ([currencies count] > 0)
                    {
                        NSMutableArray *currecyNames = [[NSMutableArray alloc] init];
                        for (NSDictionary *currDict in currencies)
                        {
                            [currecyNames addObject:[currDict valueForKey:@"currency"]];
                        }
                        [[NSUserDefaults standardUserDefaults] setObject:currecyNames forKey:@"Selected_Currencies"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"Selected_Currencies"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
            }
            
        }
        else if([webCall isEqualToString:@"get_budget_details"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
                NSDictionary *budgetDict = [response valueForKey:@"trip_details"];
                if (budgetDict)
                {
                    self.budgetValueLabel.text = [NSString stringWithFormat:@"$%.2f",[[budgetDict valueForKey:@"budget"] doubleValue]];
                    self.totalSpentValueLabel.text = [NSString stringWithFormat:@"$%.2f",[[budgetDict valueForKey:@"total_spent"] doubleValue]];
                    self.remainingValueLabel.text = [NSString stringWithFormat:@"$%.2f",[[budgetDict valueForKey:@"budget"] doubleValue] - [[budgetDict valueForKey:@"total_spent"] doubleValue]];
                }
            }
        }
        else if([webCall isEqualToString:@"get_student_budget_details"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
                NSDictionary *budgetDict = [response valueForKey:@"trip_details"];
                if (budgetDict)
                {
                   
                    self.totalSpentValueLabel.text = [NSString stringWithFormat:@"$%.2f",[[budgetDict valueForKey:@"total_spent"] doubleValue]];
                }
            }
            
        }
        else if([webCall isEqualToString:@"isArchived"])
        {
           NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
                NSDictionary *dict = [response valueForKey:@"trip_details"];
                NSString *archived = [dict valueForKey:@"archived"];
                
                if ([archived isEqualToString:@"0"])//Not archived
                {
                    if ([homeScreenAction isEqualToString:@"View Will Appear"])
                    {
                        //Do nothing. All good.
                    }
                    else if ([homeScreenAction isEqualToString:@"Settings"])
                    {
                        SettingsContainerViewController *sts = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsContainer"];
                        sts.homeViewController = self;
                        [self.navigationController pushViewController:sts animated:YES];
                    }
                    else if([homeScreenAction isEqualToString:@"Add Receipt"])
                    {
                       AddReceiptViewController *ar = [self.storyboard instantiateViewControllerWithIdentifier:@"AddReceipt"];
                        ar.mode = @"ADD";
                        ar.homeViewController = self;
                        
                        [self addChildViewController:ar];
                        ar.view.frame = self.view.frame;
                        ar.view.alpha = 0.0;
                        [self.view addSubview:ar.view];
                        [ar didMoveToParentViewController:self];
                        [UIView animateWithDuration:1.5 animations:^{
                            ar.view.alpha = 1.0;
                        }];
                    }
                    else if([homeScreenAction isEqualToString:@"View Receipts"])
                    {
                        ReceiptsContainerViewController *vr = [self.storyboard instantiateViewControllerWithIdentifier:@"ReceiptListContainer"];
                        vr.homeViewController = self;
                        [self.navigationController pushViewController:vr animated:YES];
                    }
                    else if([homeScreenAction isEqualToString:@"View Members"]){
                        
                        MembersListViewController *ml = [self.storyboard instantiateViewControllerWithIdentifier:@"Members"];
                        ml.homeViewController = self;
                        [self.navigationController pushViewController:ml animated:YES];
                        
                    }
                }
                else // Archived. Show archived screen
                {
                    ArchivedTripViewController *at = [self.storyboard instantiateViewControllerWithIdentifier:@"TripArchived"];
                    at.delegate = self;
                    [self.navigationController pushViewController:at animated:NO];
                }
            }
        }
    }
}
@end
