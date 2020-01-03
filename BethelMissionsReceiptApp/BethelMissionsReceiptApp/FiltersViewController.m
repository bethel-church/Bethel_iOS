//
//  FiltersViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 30/05/16.
//  Copyright © 2016 Calico. All rights reserved.
//

#import "FiltersViewController.h"

@interface FiltersViewController ()
{
    double diff;
}

@property (weak, nonatomic) IBOutlet UIButton *resetAllButton;
- (IBAction)onResetAll:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *onlyMyReceiptsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *onlyMyReceiptsSwitch;
- (IBAction)onOnlyMyReceiptsSwitchValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *dateFilterLabel;
@property (weak, nonatomic) IBOutlet UILabel *showReceiptsFromAllDatesLabel;
@property (weak, nonatomic) IBOutlet UISwitch *showReceiptsFromAllDatesSwitch;
- (IBAction)onShowReceiptsFromAllDatesValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *fromDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *untilDateLabel;
@property (weak, nonatomic) IBOutlet UITextField *untilDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *fromDateTextField;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;//0 or 95
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstSeparatorHeight;//0 or 35
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleViewHeight;//0 or 145 (51 in case of date toggle)
@property (weak, nonatomic) IBOutlet UIView *middleView;


@property (nonatomic, strong) NSMutableArray* categoriesArray;
@property (nonatomic, strong) NSMutableArray* selectedCategories;
@property (weak, nonatomic) IBOutlet UILabel *categoriesFilterLabel;
@property (strong, nonatomic) UITextField * selectedTextField;
@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.resetAllButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:14.0];
    self.onlyMyReceiptsLabel.font = [UIFont fontWithName:@"OpenSans-Regular" size:16.0];
    self.dateFilterLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:16.0];
    self.categoriesFilterLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:16.0];
    self.showReceiptsFromAllDatesLabel.font = [UIFont fontWithName:@"OpenSans-Regular" size:16.0];
    self.fromDateLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:15.0];
    self.untilDateLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:15.0];
    self.fromDateTextField.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:15.0];
    self.untilDateTextField.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:15.0];
    
    NSArray *categories = [NSArray arrayWithObjects:@"All", @"Food",@"Baggage/Visa/Departure Tax",@"Airport Fees",@"Transportation", @"Lodging", @"Supplies", @"Fun Day ($25 Max)", @"Gifts/Donations", @"Other Expenses", nil];
    self.categoriesArray = [[NSMutableArray alloc] init];
    [self.categoriesArray addObjectsFromArray:categories];
    
    self.selectedCategories = [[NSMutableArray alloc] init];
    
    
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, 200)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.backgroundColor = [UIColor whiteColor];
    self.fromDateTextField.inputView = datePicker;
    self.untilDateTextField.inputView = datePicker;
    
    
    UIToolbar* pickerDoneButtonView = [[UIToolbar alloc] init];
    [pickerDoneButtonView sizeToFit];
    
    UIBarButtonItem *flexibleSpacePicker = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* pickerDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                         style:UIBarButtonItemStylePlain target:self
                                                                        action:@selector(pickerDoneButton:)];
    
    
    [pickerDoneButtonView setItems:[NSArray arrayWithObjects:flexibleSpacePicker,pickerDoneButton, nil]];
    self.fromDateTextField.inputAccessoryView = pickerDoneButtonView;
    self.untilDateTextField.inputAccessoryView = pickerDoneButtonView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    backBarButtonItem.imageInsets = UIEdgeInsetsMake(3, -10, -3, 0);
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    
    UIButton *aButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 76, 24)];
    [aButton setImage:[UIImage imageNamed:@"apply"] forState:UIControlStateNormal];
    [aButton setImage:[UIImage imageNamed:@"apply-pressed"] forState:UIControlStateHighlighted];
    [aButton setImage:[UIImage imageNamed:@"apply-pressed"] forState:UIControlStateSelected];
    [aButton addTarget:self action:@selector(onApply) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    
    self.navigationItem.rightBarButtonItem = applyButton;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar"] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:19],NSFontAttributeName,
      [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    [self showHideSections];
    
    [self loadSettings];
}

-(void)keyboardWillShow:(NSNotification*)notif
{
    if (diff <= 0)
    {
        
        CGRect keyboardRect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect windowRect = [self.view.window convertRect:keyboardRect fromWindow:nil];
        CGRect keyboardViewRect = [self.view  convertRect:windowRect fromView:nil];
        
        diff = (self.middleView.frame.origin.y + self.selectedTextField.frame.origin.y + self.selectedTextField.frame.size.height) - keyboardViewRect.origin.y;
        
        
        if (diff > 0) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                self.view.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y - diff - 10,self.view.frame.size.width,self.view.frame.size.height);
                
            }];
        }
    }
    
}

-(void)keyboardWillHide:(NSNotification*)notif
{
    
    if (diff > 0) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.view.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y + diff + 10,self.view.frame.size.width,self.view.frame.size.height);
        } completion:^(BOOL finished) {
            
            if(finished){
                
                diff = 0;
            }
            
        }];
    }
    
    
    
}

-(void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    self.selectedTextField = textField;
    return YES;
}

-(void) pickerDoneButton:(id)sender
{
    UIDatePicker * p = (UIDatePicker*)self.selectedTextField.inputView;
    self.selectedTextField.text = [self stringFromDate:p.date outputFormat:@"MMM dd, yyyy"];
    [self.selectedTextField resignFirstResponder];
     [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

-(void) loadSettings{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults valueForKey:@"Filter_Only_Mine"] && [[defaults valueForKey:@"Filter_Only_Mine"] boolValue]){
       [self.onlyMyReceiptsSwitch setOn:YES];
       
    }
    else{
        [self.onlyMyReceiptsSwitch setOn:NO];
    }
    
    if([defaults valueForKey:@"Filter_All_Dates"]){
        
        if([[defaults valueForKey:@"Filter_All_Dates"] boolValue])
        {
            [self.showReceiptsFromAllDatesSwitch setOn:YES];
            //Hide to from date section
            self.middleViewHeight.constant = 51;
        }
        else{
            
            [self.showReceiptsFromAllDatesSwitch setOn:NO];
            
            //show to from date section
            self.middleViewHeight.constant = 145;
           
            self.fromDateTextField.text = [defaults valueForKey:@"Filter_From_Date"];
            self.untilDateTextField.text = [defaults valueForKey:@"Filter_Until_Date"];
        }
        
    }
    else{
        
         [self.showReceiptsFromAllDatesSwitch setOn:YES];
        //Hide to from date section
        self.middleViewHeight.constant = 51;
        
    }
    
    if([defaults valueForKey:@"Filter_Categories"]){
       
        [self.selectedCategories removeAllObjects];
        [self.selectedCategories addObjectsFromArray:[defaults valueForKey:@"Filter_Categories"]];
    }
    else{
       [self.selectedCategories removeAllObjects];
        [self.selectedCategories addObject:@"All"];
    }
    
    [self.tableView reloadData];
    

}

-(void)showHideSections
{
    if([self.mode isEqualToString:@"Leader_Full"])
    {
        
    }
    else if([self.mode isEqualToString:@"Leader_Partial"])
    {
        self.topViewHeight.constant = 48.0;
    }
    else if([self.mode isEqualToString:@"Student"])
    {
        self.topViewHeight.constant = 0.0;
        self.firstSeparatorHeight.constant = 0.0;
        self.middleViewHeight.constant = 0.0;
    }
}

-(void)showHideDates{
    
    [self.view layoutIfNeeded];
    if([self.showReceiptsFromAllDatesSwitch isOn])
    {
        
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.middleViewHeight.constant = 51;
            [self.view layoutIfNeeded];
        }];
    }
    else{
        
        self.fromDateTextField.text = self.untilDateTextField.text = [self stringFromDate:[NSDate date] outputFormat:@"MMM dd, yyyy"];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.middleViewHeight.constant = 145;
            [self.view layoutIfNeeded];
        }];
    }
}

-(void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onApply
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Date Filter
    if (![self.showReceiptsFromAllDatesSwitch isOn])
    {
        if([self datesValid])
        {
            [defaults setValue:self.fromDateTextField.text forKey:@"Filter_From_Date"];
            [defaults setValue:self.untilDateTextField.text forKey:@"Filter_Until_Date"];
            [defaults setValue:@"NO" forKey:@"Filter_All_Dates"];
        }
        else{
            
            [[[UIAlertView alloc] initWithTitle:nil message:@"Second date should be greater than the first date." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
    }
    else{
        
        [defaults setValue:@"YES" forKey:@"Filter_All_Dates"];
        [defaults setValue:nil forKey:@"Filter_From_Date"];
        [defaults setValue:nil forKey:@"Filter_Until_Date"];
    }
    
    //Show only Mine Filter
    
    if ([self.onlyMyReceiptsSwitch isOn])
    {
        [defaults setValue:@"YES" forKey:@"Filter_Only_Mine"];
    }
    else{
        [defaults setValue:@"NO" forKey:@"Filter_Only_Mine"];
    }
    
    
    //Categories Filter
    
    [defaults setValue:self.selectedCategories forKey:@"Filter_Categories"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categoriesArray.count;
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    
    NSString *category = [self.categoriesArray objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:17.0];
    cell.textLabel.text = category;
    
    if([self.selectedCategories containsObject:category])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *category = [self.categoriesArray objectAtIndex:indexPath.row];
    
    if(indexPath.row == 0)
    {
          cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedCategories removeAllObjects];
        [self.selectedCategories addObject:category];
        
    }
    else{
        
        [self.selectedCategories removeObject:@"All"];
        
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.selectedCategories removeObject:category];
            
            if([self.selectedCategories count] == 0)
            {
               [self.selectedCategories addObject:@"All"];
            }
            
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.selectedCategories addObject:category];
            
            if([self.selectedCategories count] == 9)
            {
                [self.selectedCategories removeAllObjects];
                [self.selectedCategories addObject:@"All"];
            }
        }
    }
    
    [tableView reloadData];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}


- (IBAction)onResetAll:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:@"YES" forKey:@"Filter_All_Dates"];
    [self.showReceiptsFromAllDatesSwitch setOn:YES];
    [self showHideDates];
    
    [defaults setValue:nil forKey:@"Filter_From_Date"];
    [defaults setValue:nil forKey:@"Filter_Until_Date"];
    
    [defaults setValue:@"NO" forKey:@"Filter_Only_Mine"];
    [self.onlyMyReceiptsSwitch setOn:NO];
    
    [self.selectedCategories removeAllObjects];
    [self.selectedCategories addObject:@"All"];
    [defaults setValue:self.selectedCategories forKey:@"Filter_Categories"];
    
    [self.tableView reloadData];
    
     [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
}
- (IBAction)onOnlyMyReceiptsSwitchValueChanged:(id)sender {
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
}
- (IBAction)onShowReceiptsFromAllDatesValueChanged:(id)sender {
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    [self.selectedTextField resignFirstResponder];
    
    [self showHideDates];
    
}

-(NSString*)stringFromDate:(NSDate*)date outputFormat:(NSString*)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = format;
    return [formatter stringFromDate:date];
}

-(NSDate*) dateFromString:(NSString*)string inputFormat:(NSString*)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = format;
    return [formatter dateFromString:string];
}

-(BOOL)datesValid {
    
    NSString * fromDateString = self.fromDateTextField.text;
    NSString* untilDateString = self.untilDateTextField.text;
    
    NSDate * fromDate = [self dateFromString:fromDateString inputFormat:@"MMM dd, yyyy"];
    NSDate * untilDate = [self dateFromString:untilDateString inputFormat:@"MMM dd, yyyy"];
    
    if([untilDate timeIntervalSinceDate:fromDate] > 0 )
    {
        return YES;
    }
    
    return NO;
}
@end
