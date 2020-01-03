//
//  SettingsViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/10/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "SettingsViewController.h"
#import "IndexedButton.h"
#import "WebCalls.h"
#import "Internet.h"
@interface SettingsViewController ()
{
   
    NSInteger deletedButtonIndex;
    NSString *deletedCurrency;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)onCrossButton:(id)sender;
@property (nonatomic,strong) NSMutableArray *selectedCurrencies;
- (IBAction)onAddAnother:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *currenciesUsedLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectedCurrencies  = [[NSMutableArray alloc] init];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.selectedCurrencies removeAllObjects];
    
    NSArray *arrayFromUserDefaults = [[NSUserDefaults standardUserDefaults] valueForKey:@"Selected_Currencies"];
    
    [self.selectedCurrencies addObjectsFromArray:arrayFromUserDefaults];
    
    [self.tableView reloadData];
    
   
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    backBarButtonItem.imageInsets = UIEdgeInsetsMake(3, -10, -3, 0);
    self.parentViewController.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    self.parentViewController.navigationItem.title = [NSString stringWithFormat:@"Settings"];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:19],NSFontAttributeName,
      [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    
    
    self.currenciesUsedLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:15.0];
    self.currenciesUsedLabel.textColor = [UIColor darkGrayColor];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.selectedCurrencies.count + 2;// One for USD and other for add another
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"USDCell"];
    }
    else if(indexPath.row == self.selectedCurrencies.count + 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddAnotherCell"];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CurrecyCell"];
        
        UILabel *lblShort = (UILabel*)[cell.contentView viewWithTag:1001];
        lblShort.text = [self.selectedCurrencies objectAtIndex:indexPath.row - 1];
        lblShort.textColor = [UIColor whiteColor];
        lblShort.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:17];
        
        UILabel *lblLong = (UILabel*)[cell.contentView viewWithTag:1002];
        lblLong.text = [[WebCalls currencyFullNamesDictionary] objectForKey:[self.selectedCurrencies objectAtIndex:indexPath.row - 1]];
        lblLong.textColor = [UIColor whiteColor];
        lblLong.font = [UIFont fontWithName:@"OpenSans-Semibold" size:14];
        
        IndexedButton * btn = (IndexedButton*)[cell.contentView viewWithTag:1003];
        btn.index = indexPath;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0;
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
-(void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onCrossButton:(id)sender
{
     IndexedButton *btn = (IndexedButton*)sender;
    deletedButtonIndex = btn.index.row;
    
    if ([Internet isInternetAvailable])
    {
        deletedCurrency = [self.selectedCurrencies objectAtIndex:btn.index.row -1];
        [self.selectedCurrencies removeObjectAtIndex:btn.index.row -1];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [[WebCalls sharedWebCalls] setTripCurrencies:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] currencies:self.selectedCurrencies caller:self];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    
   
}
- (IBAction)onAddAnother:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[WebCalls sharedWebCalls] isTripArchived:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
  
    
    
}

-(void) setCurrencies:(NSMutableArray*)currencies
{
    [[NSUserDefaults standardUserDefaults] setObject:currencies forKey:@"Selected_Currencies"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
}

-(void)didGetWebResponse:(id)response forWebCall:(NSString *)webCall
{
    if (response)
    {
        if ([webCall isEqualToString:@"set_trip_currencies"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
                //[self.selectedCurrencies removeObjectAtIndex:deletedButtonIndex - 1];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:deletedButtonIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView reloadData];
                
                [[NSUserDefaults standardUserDefaults] setObject:self.selectedCurrencies forKey:@"Selected_Currencies"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                [self.selectedCurrencies addObject:deletedCurrency];
                [self.tableView reloadData];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.navigationController popToViewController:self.homeViewController animated:NO];
                });
                
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
                     SelectCurrenciesViewController *sc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCurrencies"];
                     sc.selectedCurrencies = self.selectedCurrencies;
                     sc.delegate = self;
                     sc.animatedPop = YES;
                     [self.navigationController pushViewController:sc animated:YES];
                 }
                 else
                 {
                      [self.navigationController popToViewController:self.homeViewController animated:NO];
                 }
             }
         }
        
    }
}



@end
