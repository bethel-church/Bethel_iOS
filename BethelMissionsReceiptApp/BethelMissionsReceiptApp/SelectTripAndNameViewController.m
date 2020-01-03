//
//  SelectTripViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/4/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "SelectTripAndNameViewController.h"
#import "AddBudgetAndCurrenciesViewController.h"
#import "HomeViewController.h"
//@implementation UINavigationBar (customNav)
//- (CGSize)sizeThatFits:(CGSize)size
//{
//    CGSize newSize = CGSizeMake(self.frame.size.width,100);
//  
//    return newSize;
//}
//@end

#import "Internet.h"
@interface SelectTripAndNameViewController ()
{
    NSInteger selectedIndex;
}
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
- (IBAction)onCancelSearch:(id)sender;
- (IBAction)onContinueButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelSearchButton;
@property (strong, nonatomic) NSMutableArray *filteredDataArray;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) IBOutlet UILabel *thirdLabel;
@property (strong, nonatomic) IBOutlet UILabel *fourthLabel;
- (IBAction)onBack:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *bigNavBarView;

@end

@implementation SelectTripAndNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.continueButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20.0];
    self.searchTextField.font = [UIFont fontWithName:@"OpenSans" size:14.0];
    self.cancelSearchButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14.0];
    
    selectedIndex = -1;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.searchTextField.delegate = self;
    
    self.dataArray = [[NSMutableArray alloc] init];
    self.filteredDataArray = [[NSMutableArray alloc] init];
    
     if ([self.mode isEqualToString:@"Member_Name"])
     {
         //fill data array with member names
        // NSArray *names = @[@"Amie Hilton",@"Adam Jones", @"Robin Bickel", @"Vivek Bhuria", @"Suzie Ruth",@"Sherlock Holmes", @"Fyodor Dostoyevsky", @"Guy Maupassant"];
         
         
         for (NSDictionary * dict in self.usersArray)
         {
             [[NSUserDefaults standardUserDefaults] setValue:[dict valueForKey:@"type"] forKey:@"LOGGED_IN_USERTYPE"];// -1 for logged out, 0 for member, 1 for leader.
             
             NSString *fullName;
             NSString *firstName = [dict valueForKey:@"first_name"];
             NSString *middleName = [dict valueForKey:@"middle_name"];
             NSString *lastName = [dict valueForKey:@"last_name"];
             
             if (![middleName isEqualToString:@""])
             {
                 fullName = [NSString stringWithFormat:@"%@ %@ %@", firstName,middleName,lastName];
             }
             else
             {
                 fullName =  [NSString stringWithFormat:@"%@ %@", firstName,lastName];
             }
             
             [self.dataArray addObject:fullName];
         }
     }
     else
     {
         //fill data array with trip names
         for (NSDictionary * dict in self.tripsArray)
         {
              [self.dataArray addObject:[dict valueForKey:@"name"]];
         }
     }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:self.searchTextField];
    
    //Set top labels
    
    self.firstLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.secondLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14];
    
    NSString *boldText = @"Select your name";
    NSString *normalText = @"from the list so we know";
    
    NSString *fullString = [NSString stringWithFormat:@"%@ %@", boldText,normalText];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fullString];
    
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Bold" size:14.0]} range:[fullString rangeOfString:boldText]];
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:14.0]} range:[fullString rangeOfString:normalText]];
    
    self.thirdLabel.attributedText = attributedString;
    self.fourthLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.mode isEqualToString:@"Member_Name"])
    {
        self.navigationController.navigationBar.hidden = YES;
        self.heightConstraint.constant = 120;
        [self.view layoutIfNeeded];
        [self.bigNavBarView setHidden:NO];
    }
    else
    {
        self.navigationController.navigationBar.hidden = NO;
        self.navigationController.navigationBar.translucent = NO;
        
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
        backBarButtonItem.imageInsets = UIEdgeInsetsMake(3, -10, -3, 0);
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:19],NSFontAttributeName,
          [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
        
        self.heightConstraint.constant = 0;
        [self.view layoutIfNeeded];
        [self.bigNavBarView setHidden:YES];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripCell"];
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:17.0];
    
    if ([self.mode isEqualToString:@"Member_Name"])
    {
       
        if (self.searchTextField.text.length > 0)
        {
            NSString *fullString = [self.filteredDataArray objectAtIndex:indexPath.row];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fullString];
            NSArray *components = [fullString componentsSeparatedByString:@" "];
            
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:17.0]} range:[fullString rangeOfString:[components objectAtIndex:0]]];
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Bold" size:17.0]} range:[fullString rangeOfString:[components objectAtIndex:1]]];
            
            if (components.count == 3) // if there is a middle name too.
            {
                [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Bold" size:17.0]} range:[fullString rangeOfString:[components objectAtIndex:2]]];
            }
            
           
            cell.textLabel.attributedText = attributedString;
        }
        else
        {
            NSString *fullString = [self.dataArray objectAtIndex:indexPath.row];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fullString];
            NSArray *components = [fullString componentsSeparatedByString:@" "];
            
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:17.0]} range:[fullString rangeOfString:[components objectAtIndex:0]]];
            
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Bold" size:17.0]} range:[fullString rangeOfString:[components objectAtIndex:1]]];
            
            if (components.count == 3)// if there is a middle name too.
            {
                [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Bold" size:17.0]} range:[fullString rangeOfString:[components objectAtIndex:2]]];
            }
            cell.textLabel.attributedText = attributedString;
        }
        
        if (selectedIndex == indexPath.row)
        {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [cell.textLabel setTextColor:[UIColor colorWithRed:0/256.0 green:176/256.0 blue:234/256.0 alpha:1.0]];
            
        }
        else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell.textLabel setTextColor:[UIColor blackColor]];
        }
    }
    else
    {
        if (self.searchTextField.text.length > 0)
        {
            cell.textLabel.text = [self.filteredDataArray objectAtIndex:indexPath.row];
        }
        else
        {
            cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
        }
        
        if (selectedIndex == indexPath.row)
        {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [cell.textLabel setTextColor:[UIColor colorWithRed:0/256.0 green:176/256.0 blue:234/256.0 alpha:1.0]];
            
        }
        else
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell.textLabel setTextColor:[UIColor blackColor]];
        }
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchTextField resignFirstResponder];
    [self.continueButton setEnabled:YES];
    selectedIndex = indexPath.row;
   // [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    [cell.textLabel setTextColor:[UIColor colorWithRed:0/256.0 green:176/256.0 blue:234/256.0 alpha:1.0]];
    
   
    [tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.0;
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
    for (NSString *str in self.dataArray)
    {
        NSRange range = [str rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (range.length > 0)
        {
            [self.filteredDataArray addObject:str];
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
    selectedIndex = -1;
    [self.continueButton setEnabled:NO];
    [self filterContentForSearchText:tf.text];
}
- (IBAction)onCancelSearch:(id)sender
{
    self.searchTextField.text = @"";
    [self.searchTextField resignFirstResponder];
    selectedIndex = -1;
    [self.tableView reloadData];
}

- (IBAction)onContinueButton:(id)sender
{
    NSString * selectedTripOrName;
    
    if (self.searchTextField.text.length > 0)
    {
       selectedTripOrName = [self.filteredDataArray objectAtIndex:selectedIndex];
    }
    else
    {
        selectedTripOrName = [self.dataArray objectAtIndex:selectedIndex];
    }
    
    if ([self.mode isEqualToString:@"Member_Name"])
    {
        [Internet addActivityIndicator];
        for (NSDictionary * dict in self.usersArray)
        {
            NSString *fullName;
            NSString *firstName = [dict valueForKey:@"first_name"];
            NSString *middleName = [dict valueForKey:@"middle_name"];
            NSString *lastName = [dict valueForKey:@"last_name"];
            
            if (![middleName isEqualToString:@""])
            {
                fullName = [NSString stringWithFormat:@"%@ %@ %@", firstName,middleName,lastName];
            }
            else
            {
                fullName =  [NSString stringWithFormat:@"%@ %@", firstName,lastName];
            }
            
            if ([selectedTripOrName isEqual:fullName])
            {
                 [Internet removeActivityIndicator];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue:fullName forKey:@"USER_NAME"];
                NSString *userType = [defaults valueForKey:@"LOGGED_IN_USERTYPE"];
                NSDictionary *tripDict = [defaults objectForKey:@"SELECTED_TRIP"];
                
                if (([userType integerValue] > 0) && ([[tripDict valueForKey:@"budget"] integerValue] == 0))//lead or main lead AND trip budget not set yet.
                {
                    AddBudgetAndCurrenciesViewController *abc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddBudget"];
                        abc.userName = fullName;
                    [self.navigationController pushViewController:abc animated:YES];
                }
                else
                {
                   HomeViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
                   home.userName = fullName;
                   [self.navigationController pushViewController:home animated:YES];
                   
                }
                
                
                
                break;
            }
        }
        
        
    }
    else
    {
         [Internet addActivityIndicator];
        for (NSDictionary * dict in self.tripsArray)
        {
           
           if ([selectedTripOrName isEqualToString:[dict valueForKey:@"name"]])
            {
                [Internet removeActivityIndicator];
                [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"SELECTED_TRIP"];
                [self.delegate selectedTrip:[dict valueForKey:@"name"]];
                [self.navigationController popViewControllerAnimated:YES];
                 break;
            }
        }
    }
}

- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
