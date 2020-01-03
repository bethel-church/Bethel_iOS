//
//  ChooseCurrencyViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/10/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "ChooseCurrencyViewController.h"
#import "WebCalls.h"

@interface ChooseCurrencyViewController ()
{
    NSInteger selectedIndex;
}
- (IBAction)onClose:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onSelectCurrency:(id)sender;
@property (nonatomic,strong) NSMutableArray *currenciesArray;
@property (strong, nonatomic) IBOutlet UIButton *selectCurrencyButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableTopSpaceConstraint;

@end

@implementation ChooseCurrencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndex = -1;
    [self.selectCurrencyButton setEnabled:NO];
    
    self.currenciesArray = [[NSMutableArray alloc] init];
    NSArray *arrayFromUserDefaults = [[NSUserDefaults standardUserDefaults] valueForKey:@"Selected_Currencies"];
    
    [self.currenciesArray addObjectsFromArray:arrayFromUserDefaults];
    [self.currenciesArray insertObject:@"USD" atIndex:0];
    
    self.firstLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:14];
    self.secondLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:14];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:40/256.0 green:40/256.0 blue:40/256.0 alpha:0.9];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults valueForKey:@"LOGGED_IN_USERTYPE"] isEqualToString:@"0"])
    {
        [self.firstLabel setHidden:YES];
        [self.secondLabel setHidden:YES];
        self.tableTopSpaceConstraint.constant = 46;
        [self.view layoutIfNeeded];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currenciesArray.count;
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CurrencyCell"];
    
    if (indexPath.row == selectedIndex)
    {
        UILabel *lblShort = (UILabel*)[cell.contentView viewWithTag:1001];
        lblShort.text = [self.currenciesArray objectAtIndex:indexPath.row];
        lblShort.textColor = [UIColor whiteColor];
        lblShort.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:17];
        
        UILabel *lblLong = (UILabel*)[cell.contentView viewWithTag:1002];
        if (indexPath.row == 0)
        {
            lblLong.text = @"United States Dollar";
        }
        else
        {
           lblLong.text = [[WebCalls currencyFullNamesDictionary] objectForKey:[self.currenciesArray objectAtIndex:indexPath.row]];
        }
        
        lblLong.textColor = [UIColor whiteColor];
        lblLong.font = [UIFont fontWithName:@"OpenSans-Semibold" size:14];
        
        UIView *backView = [cell.contentView viewWithTag:1003];
        backView.backgroundColor = [UIColor colorWithRed:68/256.0 green:88/256.0 blue:92/256.0 alpha:1.0];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        backView.layer.cornerRadius = 5.0;
        backView.clipsToBounds = YES;
        
    }
    else
    {
        UILabel *lblShort = (UILabel*)[cell.contentView viewWithTag:1001];
        lblShort.text = [self.currenciesArray objectAtIndex:indexPath.row];
        lblShort.textColor = [UIColor lightGrayColor];
        lblShort.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:17];
        
        UILabel *lblLong = (UILabel*)[cell.contentView viewWithTag:1002];
        if (indexPath.row == 0)
        {
            lblLong.text = @"United States Dollar";
        }
        else
        {
            lblLong.text = [[WebCalls currencyFullNamesDictionary] objectForKey:[self.currenciesArray objectAtIndex:indexPath.row]];
        }
        lblLong.textColor = [UIColor lightGrayColor];
        lblLong.font = [UIFont fontWithName:@"OpenSans-Semibold" size:14];
        
        UIView *backView = [cell.contentView viewWithTag:1003];
        backView.backgroundColor = [UIColor colorWithRed:218.0/256.0 green:218.0/256.0 blue:218.0/256.0 alpha:1.0];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        backView.layer.cornerRadius = 5.0;
        backView.clipsToBounds = YES;
    }
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    selectedIndex = indexPath.row;
    
    [self.tableView reloadData];
    
    [self.selectCurrencyButton setEnabled:YES];
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

- (IBAction)onClose:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self willMoveToParentViewController:nil];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        });
    }];
}
- (IBAction)onSelectCurrency:(id)sender {
    
    if (selectedIndex == 0)
    {
        [self.currencyDelegate setCurrency:@"USD"];
    }
    else
    {
        //Just return short form for now
        //[self.currencyDelegate setCurrency:[[WebCalls currencyFullNamesDictionary] objectForKey:[self.currenciesArray objectAtIndex:selectedIndex]]];
         [self.currencyDelegate setCurrency:[self.currenciesArray objectAtIndex:selectedIndex]];
    }
    
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self willMoveToParentViewController:nil];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        });
    }];
    
}
@end
