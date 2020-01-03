//
//  ChooseCategoryViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/11/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "ChooseCategoryViewController.h"

@interface ChooseCategoryViewController ()
{
    NSInteger selectedIndex;
}
- (IBAction)onClose:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
- (IBAction)onSelectCategoryButton:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * categoriesArray;
@property (strong, nonatomic) IBOutlet UIButton *selectCategoryButton;
@end

@implementation ChooseCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    selectedIndex = -1;
    self.categoriesArray = [[NSMutableArray alloc] init];
   
    NSArray *categories = [NSArray arrayWithObjects:@"Food",@"Baggage/Visa/Departure Tax",@"Airport Fees",@"Transportation", @"Lodging", @"Supplies", @"Missions $25 per person (Not 2nd Year)", @"Gifts/Donations", @"Other Expenses", nil];
    
    [self.categoriesArray addObjectsFromArray:categories];
   
    
    self.firstLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:16];
    self.firstLabel.textColor = [UIColor darkGrayColor];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:40/256.0 green:40/256.0 blue:40/256.0 alpha:0.9];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categoriesArray.count;
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    
    if (indexPath.row == selectedIndex)
    {
        UILabel *lbl= (UILabel*)[cell.contentView viewWithTag:1001];
        lbl.text = [self.categoriesArray objectAtIndex:indexPath.row];
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont fontWithName:@"OpenSans-Bold" size:16];
        lbl.layer.cornerRadius = 5.0;
        lbl.clipsToBounds = YES;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        lbl.backgroundColor = [UIColor colorWithRed:68/256.0 green:88/256.0 blue:92/256.0 alpha:1.0];
    }
    else
    {
        UILabel *lbl = (UILabel*)[cell.contentView viewWithTag:1001];
        lbl.text = [self.categoriesArray objectAtIndex:indexPath.row];
        lbl.textColor = [UIColor lightGrayColor];
        lbl.font = [UIFont fontWithName:@"OpenSans-Bold" size:16];
        lbl.layer.cornerRadius = 5.0;
        lbl.clipsToBounds = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        lbl.backgroundColor = [UIColor colorWithRed:218.0/256.0 green:218.0/256.0 blue:218.0/256.0 alpha:1.0];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    selectedIndex = indexPath.row;
    
    [self.tableView reloadData];
    [self.selectCategoryButton setEnabled:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClose:(id)sender {
    
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
- (IBAction)onSelectCategoryButton:(id)sender {
    
    [self.categoryDelegate setCategory:[self.categoriesArray objectAtIndex:selectedIndex]];
    
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
