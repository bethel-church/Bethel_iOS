//
//  MembersListViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 24/05/16.
//  Copyright © 2016 Calico. All rights reserved.
//

#import "MembersListViewController.h"
#import "UserReceiptsListTableViewController.h"

@interface MembersListViewController ()
{
    
}
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)onCancelButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * membersArray;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (strong, nonatomic) NSMutableArray *filteredDataArray;
@end

@implementation MembersListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray = [[NSMutableArray alloc] init];
    self.filteredDataArray = [[NSMutableArray alloc] init];
    
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.searchTextField.delegate = self;
    
    
}

-(void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
   
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    backBarButtonItem.imageInsets = UIEdgeInsetsMake(3, -10, -3, 0);
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar"] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:19],NSFontAttributeName,
      [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.searchTextField];
    
    [[WebCalls sharedWebCalls] getUserDetails:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeHoveringTotal];
 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.searchTextField];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchTextField.text.length > 0)
    {
        return [self.filteredDataArray count];
    }
    else
    {
        return  [self.dataArray count];
    }
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberCell"];
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:17.0];
    NSDictionary *user;
    
    if (self.searchTextField.text.length > 0)
    {
        user = (NSDictionary*)[self.filteredDataArray objectAtIndex:indexPath.row];
        
        
    }
    else
    {
        user = (NSDictionary*)[self.dataArray objectAtIndex:indexPath.row];
    }
    
    NSString * middleName = [user valueForKey:@"middle_name"];
    if (! middleName || [middleName isEqualToString:@""])
    {
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ ($%0.02f)",[user valueForKey:@"first_name"],[user valueForKey:@"last_name"],[[user valueForKey:@"total_spent"] doubleValue]];
    }
    else{
        
       cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@ ($%0.02f)",[user valueForKey:@"first_name"],[user valueForKey:@"middle_name"],[user valueForKey:@"last_name"],[[user valueForKey:@"total_spent"] doubleValue]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchTextField resignFirstResponder];
    [tableView reloadData];
    
    UserReceiptsListTableViewController *ur = [self.storyboard instantiateViewControllerWithIdentifier:@"UserReceipts"];
    ur.homeViewController = self.homeViewController;
    
    NSDictionary *user;
    if (self.searchTextField.text.length > 0){
       
        user = (NSDictionary*)[self.filteredDataArray objectAtIndex:indexPath.row];
    }
    else{
        
         user = (NSDictionary*)[self.dataArray objectAtIndex:indexPath.row];
    }
    
    ur.user = user;
    
    [self.navigationController pushViewController:ur animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.0;
}

-(void) onBack:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)filterContentForSearchText:(NSString*)searchText
{
    [self.filteredDataArray removeAllObjects];
    for (NSDictionary *user in self.dataArray)
    {
        NSString * nameString;
        NSString * middleName = [user valueForKey:@"middle_name"];
        if (! middleName || [middleName isEqualToString:@""])
        {
           nameString = [NSString stringWithFormat:@"%@ %@ ($%0.02f)",[user valueForKey:@"first_name"],[user valueForKey:@"last_name"],[[user valueForKey:@"total_spent"] doubleValue]];
        }
        else{
            
             nameString = [NSString stringWithFormat:@"%@ %@ %@ ($%0.02f)",[user valueForKey:@"first_name"],[user valueForKey:@"middle_name"],[user valueForKey:@"last_name"],[[user valueForKey:@"total_spent"] doubleValue]];
        }
        
        NSRange range = [nameString rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (range.length > 0)
        {
            [self.filteredDataArray addObject:user];
        }
    }
    [self.tableView reloadData];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldTextDidChange:(NSNotification*)notif
{
    UITextField * tf = notif.object;
    
    [self filterContentForSearchText:tf.text];
}


- (IBAction)onCancelButton:(id)sender {
    
    self.searchTextField.text = @"";
    [self.searchTextField resignFirstResponder];
    
    [self.tableView reloadData];
}

-(void)didGetWebResponse:(id)response forWebCall:(NSString *)webCall{
 
    if (response)
    {
        if ([webCall isEqualToString:@"get_user_details"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
                NSDictionary * dict = [response valueForKey:@"data"];
                NSArray * users = [dict valueForKey:@"User"];
                
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:users];
                
                [self.tableView reloadData];
                
                [self addHoveringTotal];
            }
        }
        
    }
}

-(void) addHoveringTotal{
    
    AppDelegate * delg = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIWindow *appWindow = [delg window];
    
    [[appWindow viewWithTag:213143] removeFromSuperview];
    
    
    //total spent
    UIView * hover = [[UIView alloc] initWithFrame:CGRectMake(10.0, [[UIScreen mainScreen] bounds].size.height - 60, 100, 50)];
    hover.backgroundColor = [UIColor colorWithRed:41/256.0 green:75/256.0 blue:82/256.0 alpha:1.0];
    hover.tag = 213143;
    
    hover.layer.cornerRadius = 5.0;
    hover.clipsToBounds = YES;
    
    hover.alpha = 0.9;
    
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 100, 30)];
    amountLabel.textAlignment = NSTextAlignmentCenter;
    amountLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20];
    amountLabel.text = [NSString stringWithFormat:@"$%0.02f",[self calculateTotalSpent]];
    amountLabel.textColor = [UIColor whiteColor];
    [hover addSubview:amountLabel];
    
    UILabel *totalSpentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 27, 100, 20)];
    totalSpentLabel.textAlignment = NSTextAlignmentCenter;
    totalSpentLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:11];
    totalSpentLabel.text = @"Total Spent";
    totalSpentLabel.textColor = [UIColor whiteColor];
    [hover addSubview:totalSpentLabel];
    
    [appWindow addSubview:hover];
    
    
    
}

-(double) calculateTotalSpent
{
    double total = 0.0;
    
    for(NSDictionary * user in self.dataArray){
        
        total += [[user valueForKey:@"total_spent"] doubleValue];
    }
    return total;
}



-(void) removeHoveringTotal{
    
    AppDelegate * delg = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIWindow *appWindow = [delg window];
    
    [[appWindow viewWithTag:213143] removeFromSuperview];
    
}

@end
