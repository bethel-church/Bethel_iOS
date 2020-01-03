//
//  SelectCurrenciesViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/9/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "SelectCurrenciesViewController.h"
#import "WebCalls.h"

@interface SelectCurrenciesViewController ()
- (IBAction)onSave:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *currenciesArray;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarItem;
@property (strong, nonatomic) NSMutableArray *tempSelectedCurrencies;

@end

@implementation SelectCurrenciesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.currenciesArray = [[NSMutableArray alloc] init];
    self.tempSelectedCurrencies = [[NSMutableArray alloc] init];
    
    [self.tempSelectedCurrencies  addObjectsFromArray:self.selectedCurrencies];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENCIES"];
    NSArray<NSString *> *keys = dict.allKeys;
    for (NSString *key in keys) {
        NSDictionary *currencyDict = dict[key];
        NSString *code = currencyDict[@"code"];
        [self.currenciesArray addObject:code];
    }
    
//    NSDictionary *list = [dict valueForKey:@"list"];
//    NSArray *resources = [list valueForKey:@"resources"];
//
//    for (NSDictionary * resource in resources) {
//
//        NSDictionary *res = [resource valueForKey:@"resource"];
//        NSDictionary * fields = [res valueForKey:@"fields"];
//        NSString *usdString = [fields valueForKey:@"name"];
//        if ([usdString containsString:@"/"])
//        {
//            NSArray * components = [usdString componentsSeparatedByString:@"/"];
//            NSString *currencyShort = [components objectAtIndex:1];
//
//            [self.currenciesArray addObject:currencyShort];
//        }
//    }
    
    self.currenciesArray = [[self.currenciesArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
    }] mutableCopy];
    
    //[self.currenciesArray arrayByAddingObjectsFromArray:sortedArray];
    
    [self.currenciesArray insertObject:@"None" atIndex:0];
    
    [self.tableView reloadData];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    backBarButtonItem.imageInsets = UIEdgeInsetsMake(3, -10, -3, 0);
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
   
    UIBarButtonItem *saveBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(onSave:)];
    [saveBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:16],NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [saveBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:16],NSFontAttributeName,[UIColor lightGrayColor],NSForegroundColorAttributeName, nil] forState:UIControlStateDisabled];
    
    [saveBarButtonItem setTitlePositionAdjustment:UIOffsetMake(-4, 3) forBarMetrics:UIBarMetricsDefault];
   // saveBarButtonItem.imageInsets = UIEdgeInsetsMake(3, -10, -3, 0);
    self.saveBarItem = saveBarButtonItem;
    self.navigationItem.rightBarButtonItem = saveBarButtonItem;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:19],NSFontAttributeName,
      [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
//    if (self.tempSelectedCurrencies.count > 0)
//    {
//        [self.saveBarItem setEnabled:YES];
//    }
//    else
//    {
        [self.saveBarItem setEnabled:NO];
//    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currenciesArray count];
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CurrencyCell"];
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:16.0];
    
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = [self.currenciesArray objectAtIndex:indexPath.row];
    }
    else
    {
        cell.textLabel.text = [[WebCalls currencyFullNamesDictionary] objectForKey:[self.currenciesArray objectAtIndex:indexPath.row]];
    }
    
    
    UILabel *shortName = (UILabel *)[cell.contentView viewWithTag:1001];
    shortName.font = [UIFont fontWithName:@"OpenSans" size:16.0];
    if (indexPath.row == 0)
    {
         shortName.text = @"";
    }
    else
    {
         shortName.text = [self.currenciesArray objectAtIndex:indexPath.row];
    }
   
   
    
    if ([self.tempSelectedCurrencies containsObject:[self.currenciesArray objectAtIndex:indexPath.row]])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [cell.textLabel setTextColor:[UIColor colorWithRed:0/256.0 green:176/256.0 blue:234/256.0 alpha:1.0]];
        [shortName setTextColor:[UIColor colorWithRed:0/256.0 green:176/256.0 blue:234/256.0 alpha:1.0]];
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [shortName setTextColor:[UIColor blackColor]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *shortName = (UILabel *)[cell.contentView viewWithTag:1001];
    
    //User selected None
    if (indexPath.row == 0)
    {
        [self.tempSelectedCurrencies removeAllObjects];
        [self.saveBarItem setEnabled:YES];
        [self.tableView reloadData];
        
        return;
    }
    
    //user selects an already selected cell
    if ([self.tempSelectedCurrencies containsObject:[self.currenciesArray objectAtIndex:indexPath.row]])
    {
        [self.tempSelectedCurrencies removeObject:[self.currenciesArray objectAtIndex:indexPath.row]];
        
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [shortName setTextColor:[UIColor blackColor]];
        
    }
    else //user selects some other cell.
    {
        if ([self.tempSelectedCurrencies count] < 5)
        {
            [self.tempSelectedCurrencies addObject:[self.currenciesArray objectAtIndex:indexPath.row]];
           [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
           [cell.textLabel setTextColor:[UIColor colorWithRed:0/256.0 green:176/256.0 blue:234/256.0 alpha:1.0]];
           [shortName setTextColor:[UIColor colorWithRed:0/256.0 green:176/256.0 blue:234/256.0 alpha:1.0]];
            
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[[UIAlertView alloc] initWithTitle:@"Five already Selected!" message:@"A maximum of 5 currucies can be selected for a trip." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                
            });
            
        }
    }
    
//    if (self.tempSelectedCurrencies.count > 0)
//    {
        [self.saveBarItem setEnabled:YES];
//    }
//    else
//    {
//        [self.saveBarItem setEnabled:NO];
//    }
   
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.0;
}

-(void)onBack:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:self.animatedPop];
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

- (IBAction)onSave:(id)sender {
 
    if ([Internet isInternetAvailable])
    {
        [self.selectedCurrencies removeAllObjects];
        [self.selectedCurrencies addObjectsFromArray:self.tempSelectedCurrencies];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [[WebCalls sharedWebCalls] setTripCurrencies:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] currencies:self.selectedCurrencies caller:self];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    
}

-(void) didGetWebResponse:(id)response forWebCall:(NSString *)webCall
{
    if (response)
    {
        if ([webCall isEqualToString:@"set_trip_currencies"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
               
                [self.delegate setCurrencies:self.selectedCurrencies];
                [self.navigationController popViewControllerAnimated:self.animatedPop];
            }
           
            
        }
       
    }
}

@end
