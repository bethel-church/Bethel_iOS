//
//  ViewReceiptsTableViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/14/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "ViewReceiptsTableViewController.h"
#import "CustomTableViewCell.h"
#import "ReceiptImageViewController.h"
#import "AddReceiptViewController.h"
#import "AppDelegate.h"
#import "IndexedButton.h"
#import "FiltersViewController.h"

@interface ViewReceiptsTableViewController ()
{
    CGFloat btnheight;
    NSMutableArray *rowHeights;
    NSInteger swipedIndex;
    NSInteger rowCountUploadedReceipts;
    NSInteger rowCountSavedReceipts;
    NSString *userAction;
   
    NSString *mode; // "UPLOADED" or "SAVED"
    NSManagedObjectContext *managedContext;
    NSInteger currentUploadingReceiptIndex;
    
    NSInteger firstTime;
    
    UIButton *uploadAllButton;
    NSInteger totalReceptsTobeUploaded;
    NSInteger totalReceiptsUploaded;
}

@property (nonatomic,strong) NSMutableArray* receiptsDataArray;
@property (nonatomic,strong) NSMutableArray* savedReceiptsDataArray;
@property (nonatomic,strong) NSMutableArray* managedObjects;
@property (nonatomic,strong) NSMutableArray* userDataArray;

@property (nonatomic,strong) NSMutableArray* unFilteredReceiptsDataArray;
@property (nonatomic,strong) NSMutableArray* unFilteredSavedReceiptsDataArray;
@property (nonatomic,strong) NSMutableArray* unFilteredManagedObjects;
@property (nonatomic,strong) NSMutableArray* unFilteredUserDataArray;


- (IBAction)onSwipeLeft:(id)sender;
- (IBAction)onSwipeRight:(id)sender;

@end

@implementation ViewReceiptsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    rowHeights = [[NSMutableArray alloc] init];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    self.unFilteredReceiptsDataArray = [[NSMutableArray alloc] init];
    self.unFilteredSavedReceiptsDataArray = [[NSMutableArray alloc] init];
    self.unFilteredManagedObjects = [[NSMutableArray alloc] init];
    self.unFilteredUserDataArray = [[NSMutableArray alloc] init];
    
    self.receiptsDataArray = [[NSMutableArray alloc] init];
    self.savedReceiptsDataArray = [[NSMutableArray alloc] init];
    self.managedObjects = [[NSMutableArray alloc] init];
    self.userDataArray = [[NSMutableArray alloc] init];
    
    firstTime = 0;
    swipedIndex = -1;
    currentUploadingReceiptIndex = -1;
    rowCountUploadedReceipts = [self.receiptsDataArray count];
    rowCountSavedReceipts  = [self.savedReceiptsDataArray count];
    
    managedContext = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Receipts"];
    NSMutableArray * managedObjects = [[managedContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    rowCountSavedReceipts = managedObjects.count;
    
    mode = @"UPLOADED";
    
    totalReceptsTobeUploaded = 0;
     totalReceiptsUploaded = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    backBarButtonItem.imageInsets = UIEdgeInsetsMake(3, -10, -3, 0);
    
    self.parentViewController.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    UIButton *fButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 76, 24)];
    [fButton setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [fButton setImage:[UIImage imageNamed:@"filter-pressed"] forState:UIControlStateHighlighted];
    [fButton setImage:[UIImage imageNamed:@"filter-pressed"] forState:UIControlStateSelected];
    [fButton addTarget:self action:@selector(onFilter) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *filterButtonItem = [[UIBarButtonItem alloc] initWithCustomView:fButton];
    self.parentViewController.navigationItem.rightBarButtonItem = filterButtonItem;
    
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.parentViewController.navigationItem.title = [NSString stringWithFormat:@"Receipts"];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar"] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:19],NSFontAttributeName,
      [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    UISegmentedControl * segment = (UISegmentedControl*)[self.parentViewController.view viewWithTag:3131];
    [segment setTitle:[NSString stringWithFormat:@"Uploaded (%d)",rowCountUploadedReceipts] forSegmentAtIndex:0];
    [segment setTitle:[NSString stringWithFormat:@"Saved For Later (%d)",rowCountSavedReceipts] forSegmentAtIndex:1];
    
    if(firstTime == 0)
    {
        [self.tableView reloadData];
    }
    else{
        
        if([mode isEqualToString:@"UPLOADED"]){
            
            [self segmentControlValueChanged:0];
        }
        else{
            [self segmentControlValueChanged:1];
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults valueForKey:@"LOGGED_IN_USERTYPE"] isEqualToString:@"0"])
    {
        [[WebCalls sharedWebCalls] getReceipts:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] userName:[defaults valueForKey:@"USER_NAME"] caller:self];
    }
    else
    {
        [[WebCalls sharedWebCalls] getReceipts:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] userName:nil caller:self];
    }
    
    firstTime = 1;
}

-(void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onFilter
{
 
    FiltersViewController *fl = [self.storyboard instantiateViewControllerWithIdentifier:@"Filters"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults valueForKey:@"LOGGED_IN_USERTYPE"] isEqualToString:@"0"])
    {
       fl.mode = @"Leader_Partial";
    }
    else{
        
        fl.mode = @"Leader_Full";
    }
    [self.navigationController pushViewController:fl animated:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
   // self.navigationController.navigationBarHidden = YES;
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    if ([mode isEqualToString:@"UPLOADED"]){
        
         return [self.receiptsDataArray count];
    }
    else{
        
        return [self.savedReceiptsDataArray count];
    }
   
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *receiptDict;
    NSDictionary *userDict;
    
    
    
    
    if ([mode isEqualToString:@"UPLOADED"]){
        
        receiptDict = (NSDictionary*)[self.receiptsDataArray objectAtIndex:indexPath.row];
        userDict = (NSDictionary*)[self.userDataArray objectAtIndex:indexPath.row];
    }
    else{
        
        receiptDict = (NSDictionary*)[self.savedReceiptsDataArray objectAtIndex:indexPath.row];
        userDict = nil;
    }
    
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiptCell" forIndexPath:indexPath];
    
    //add top line to first cell
    [[cell.contentView viewWithTag:7275] removeFromSuperview];
    
    if(indexPath.row == 0)
    {
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 0.5)];
        topLineView.backgroundColor = [UIColor colorWithRed:227/256.0 green:227/256.0 blue:227/256.0 alpha:1.0];
        topLineView.tag = 7275;
        [cell.contentView addSubview:topLineView];
    }
    
    
    
    //Add swipe gestures
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [cell addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [cell addGestureRecognizer:rightSwipe];
    
    UILabel *nameLabel = (UILabel*)[cell.contentView viewWithTag:1001];
    nameLabel.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:17];
    
    UILabel *dateTimeLable = (UILabel*)[cell.contentView viewWithTag:1002];
    dateTimeLable.font = [UIFont fontWithName:@"OpenSans-Bold" size:14];
    
    UILabel *typeLabel = (UILabel*)[cell.contentView viewWithTag:1003];
    typeLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:16];
    
    UILabel *descriptionLabel = (UILabel*)[cell.contentView viewWithTag:1004];
    descriptionLabel.font = [UIFont fontWithName:@"OpenSans" size:15];
    
    UILabel *priceLabel = (UILabel*)[cell.contentView viewWithTag:1005];
    priceLabel.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:15];
    
    UILabel *usdLabel = (UILabel*)[cell.contentView viewWithTag:1006];
    usdLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    
    UILabel *editedLabel = (UILabel*)[cell.contentView viewWithTag:1007];
    editedLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15];
   
    
    //Remove buttons
    [[cell.contentView viewWithTag:1008] removeFromSuperview];
    [[cell.contentView viewWithTag:1009] removeFromSuperview];
    [[cell.contentView viewWithTag:10010] removeFromSuperview];
    
    
    UIButton * buttonReceipt = [UIButton buttonWithType:UIButtonTypeCustom];
    //[buttonReceipt setBackgroundImage:[UIImage imageNamed:@"receipt"] forState:UIControlStateNormal];
    buttonReceipt.backgroundColor = [UIColor colorWithRed:175/255.0 green:175/255.0 blue:175/255.0 alpha:1.0];
    //[buttonReceipt setTitle:@"View" forState:UIControlStateNormal];
    //[buttonReceipt.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    [buttonReceipt setImage:[UIImage imageNamed:@"receipt-icon"] forState:UIControlStateNormal];
    buttonReceipt.tag = 1008;
    buttonReceipt.frame = CGRectMake(305, 0, 80,180);
    [buttonReceipt addTarget:self action:@selector(righViewsTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:buttonReceipt];
    
    UIButton * buttonEdit = [UIButton buttonWithType:UIButtonTypeCustom];
//    [buttonEdit setBackgroundImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    buttonEdit.backgroundColor = [UIColor colorWithRed:67/255.0 green:151/255.0 blue:160/255.0 alpha:1.0];
    //[buttonEdit setTitle:@"Edit" forState:UIControlStateNormal];
    // [buttonEdit.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    [buttonEdit setImage:[UIImage imageNamed:@"edit-icon"] forState:UIControlStateNormal];
    buttonEdit.tag = 1009;
    buttonEdit.frame = CGRectMake(310, 0, 80, 180);
    [buttonEdit addTarget:self action:@selector(righViewsTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:buttonEdit];
    
    
   
 
    UIButton * buttonDelete = [UIButton buttonWithType:UIButtonTypeCustom];
   // [buttonDelete setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    buttonDelete.backgroundColor = [UIColor colorWithRed:234/255.0 green:36/255.0 blue:68/255.0 alpha:1.0];
    //[buttonDelete setTitle:@"Delete" forState:UIControlStateNormal];
    // [buttonDelete.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    [buttonDelete setImage:[UIImage imageNamed:@"delete-icon"] forState:UIControlStateNormal];
    buttonDelete.tag = 10010;
    [buttonDelete addTarget:self action:@selector(righViewsTapped:) forControlEvents:UIControlEventTouchUpInside];
    buttonDelete.frame = CGRectMake(315, 0, 80, 180);
    [cell.contentView addSubview:buttonDelete];
    
    IndexedButton * uploadButton = (IndexedButton*)[cell.contentView viewWithTag:1024];
    UIProgressView *progress = (UIProgressView*)[cell.contentView viewWithTag:1026];
    
    progress.layer.cornerRadius = 3.0;
    progress.clipsToBounds =  YES;
    if ([mode isEqualToString:@"UPLOADED"]){
        
        uploadButton.hidden = YES;
        progress.hidden = YES;
    }
    else
    {
        uploadButton.hidden = NO;
        progress.hidden = YES;
        
        [uploadButton removeTarget:self action:@selector(onUpload:) forControlEvents:UIControlEventTouchUpInside];
        
        [uploadButton addTarget:self action:@selector(onUpload:) forControlEvents:UIControlEventTouchUpInside];
        uploadButton.index = indexPath;
    }
    
    
    if ([mode isEqualToString:@"UPLOADED"]){
        
        
        if ([[receiptDict valueForKey:@"is_edited"] isEqualToString:@"0"])
        {
            [editedLabel setHidden:YES];
        }
        else
        {
            [editedLabel setHidden:NO];
        }

        
        if ([[userDict valueForKey:@"middle_name"] isEqualToString:@""])
        {
            nameLabel.text = [NSString stringWithFormat:@"%@ %@",[userDict valueForKey:@"first_name"],[userDict valueForKey:@"last_name"]];
        }
        else
        {
            nameLabel.text = [NSString stringWithFormat:@"%@ %@ %@",[userDict valueForKey:@"first_name"],[userDict valueForKey:@"middle_name"],[userDict valueForKey:@"last_name"]];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *name = [NSString stringWithFormat:@"%@",[defaults valueForKey:@"USER_NAME"] ];
        
        if ([nameLabel.text isEqualToString:name])
        {
            nameLabel.text = @"Me";
        }
        
        NSDate *d = [self dateFromString:[receiptDict valueForKey:@"receipt_date"] inputFormat:@"yyyy-MM-dd hh:mm a"];
        NSString * dateString = [self stringFromDate:d outputFormat:@"M/d/yy h:mm a"];
        dateTimeLable.text = dateString;
    }
    else{
        
        [editedLabel setHidden:YES];
        
        nameLabel.text = @"Me";
        
        NSDate *d = [self dateFromString:[receiptDict valueForKey:@"receipt_date"] inputFormat:@"yyyy-MM-dd hh:mm a"];
        NSString * dateString = [self stringFromDate:d outputFormat:@"M/d/yy h:mm a"];
        
        dateTimeLable.text = dateString;
    }
    
    typeLabel.text = [receiptDict valueForKey:@"type"];
    descriptionLabel.text = [receiptDict valueForKey:@"description"];
    priceLabel.text = [NSString stringWithFormat:@"$%.2f",[[receiptDict valueForKey:@"usd"] doubleValue]] ;
    
    cell.contentView.clipsToBounds = YES;
    return cell;
}

//-(NSString*)formatDate:(NSString*)dateString
//{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//    NSDate *date = [formatter dateFromString:dateString];
//    
//    [formatter setDateFormat:@"M/d/yy hh:mm a"];
//    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
//    
//    return [formatter stringFromDate:date];
//}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    
}

-(void)viewDidLayoutSubviews
{
    NSInteger count = [mode isEqualToString:@"UPLOADED"] ? rowCountUploadedReceipts : rowCountSavedReceipts;
    for (int i = 0 ; i < count; i++)
    {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        CGRect r = cell.contentView.bounds;
        
        UIButton *imgGrey = (UIButton*)[cell viewWithTag:1008];
        UIButton *imgGreen = (UIButton*)[cell viewWithTag:1009];
        UIButton *imgRed = (UIButton*)[cell viewWithTag:10010];
        
        imgGrey.frame = CGRectMake(305, 0, 80, r.size.height);
        imgGreen.frame = CGRectMake(310, 0, 80, r.size.height);
        imgRed.frame = CGRectMake(315, 0, 80, r.size.height);
        
        
        [rowHeights setObject:[NSNumber numberWithFloat:r.size.height] atIndexedSubscript:i];
    }
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    self.tableView.estimatedRowHeight = 100.0;
    
    return UITableViewAutomaticDimension;
}


- (IBAction)onSwipeLeft:(id)sender {
    
    
    UISwipeGestureRecognizer *ges = (UISwipeGestureRecognizer*)sender;
    
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:[ges locationInView:self.tableView]];
    CustomTableViewCell *cell = (CustomTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
    
    if (swipedIndex == -1)
    {
        UIButton *imgGrey = (UIButton*)[cell viewWithTag:1008];
        UIButton *imgGreen = (UIButton*)[cell viewWithTag:1009];
        UIButton *imgRed = (UIButton*)[cell viewWithTag:10010];
        
        swipedIndex = path.row;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self.tableView setUserInteractionEnabled:NO];
            cell.contentView.frame = CGRectMake(cell.contentView.frame.origin.x - 210, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
            imgRed.frame = CGRectMake(300 + 79 + 79, 0, 80, [[rowHeights objectAtIndex:path.row] floatValue]);
            imgGreen.frame = CGRectMake(300 + 79, 0, 80, [[rowHeights objectAtIndex:path.row] floatValue]);
            imgGrey.frame = CGRectMake(300, 0, 80, [[rowHeights objectAtIndex:path.row] floatValue]);
            
        } completion:^(BOOL finished) {
            
            [self.tableView setUserInteractionEnabled:YES];
        }];
        
    }
    else
    {
        path = [NSIndexPath indexPathForRow:swipedIndex inSection:0];
        cell = (CustomTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
        
        //swipe back the swiped row
        UIButton *imgGrey = (UIButton*)[cell viewWithTag:1008];
        UIButton *imgGreen = (UIButton*)[cell viewWithTag:1009];
        UIButton *imgRed = (UIButton*)[cell viewWithTag:10010];
        
        
        swipedIndex = -1;
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self.tableView setUserInteractionEnabled:NO];
            cell.contentView.frame = CGRectMake(cell.contentView.frame.origin.x + 210, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
            imgRed.frame = CGRectMake(315, 0, 80, [[rowHeights objectAtIndex:path.row] floatValue]);
            imgGreen.frame = CGRectMake(310, 0, 80, [[rowHeights objectAtIndex:path.row] floatValue]);
            imgGrey.frame = CGRectMake(305, 0, 80, [[rowHeights objectAtIndex:path.row] floatValue]);
            
        } completion:^(BOOL finished) {
            
            [self.tableView setUserInteractionEnabled:YES];
        }];
       
    }
    
    
    
}

- (IBAction)onSwipeRight:(id)sender {
    
    UISwipeGestureRecognizer *ges = (UISwipeGestureRecognizer*)sender;
    
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:[ges locationInView:self.tableView]];
    CustomTableViewCell *cell = (CustomTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
    
    if (swipedIndex >= 0)
    {
        if (path.row != swipedIndex)
        {
            path = [NSIndexPath indexPathForRow:swipedIndex inSection:0];
            cell = (CustomTableViewCell*)[self.tableView cellForRowAtIndexPath:path];
        }
        
        UIButton *imgGrey = (UIButton*)[cell viewWithTag:1008];
        UIButton *imgGreen = (UIButton*)[cell viewWithTag:1009];
        UIButton *imgRed = (UIButton*)[cell viewWithTag:10010];
        
        swipedIndex = -1;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self.tableView setUserInteractionEnabled:NO];
            cell.contentView.frame = CGRectMake(cell.contentView.frame.origin.x + 210, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
            imgRed.frame = CGRectMake(315, 0, 80, [[rowHeights objectAtIndex:path.row] floatValue]);
            imgGreen.frame = CGRectMake(310, 0, 80, [[rowHeights objectAtIndex:path.row] floatValue]);
            imgGrey.frame = CGRectMake(305, 0, 80, [[rowHeights objectAtIndex:path.row] floatValue]);
            
        } completion:^(BOOL finished) {
             [self.tableView setUserInteractionEnabled:YES];
        }];
       
    }
    
    
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (swipedIndex != -1)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:swipedIndex inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        
        UIImageView *imgGrey = (UIImageView*)[cell viewWithTag:1008];
        UIImageView *imgGreen = (UIImageView*)[cell viewWithTag:1009];
        UIImageView *imgRed = (UIImageView*)[cell viewWithTag:10010];
        
        swipedIndex = -1;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.tableView setUserInteractionEnabled:NO];
            cell.contentView.frame = CGRectMake(cell.contentView.frame.origin.x + 210, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
            imgRed.frame = CGRectMake(315, 0, 80, [[rowHeights objectAtIndex:path.row] floatValue]);
            imgGreen.frame = CGRectMake(310, 0, 80, [[rowHeights objectAtIndex:path.row] floatValue]);
            imgGrey.frame = CGRectMake(305, 0, 80, [[rowHeights objectAtIndex:path.row] floatValue]);
        } completion:^(BOOL finished) {
            
             [self.tableView setUserInteractionEnabled:YES];
            
        }];
        
    }
}

-(void)righViewsTapped:(UIButton*)btn
{
    
        if (swipedIndex != -1)
        {
            
            
            if (btn.tag == 1008)//View Receipt
            {
                if ([mode isEqualToString:@"UPLOADED"]){
                    
                    if ([Internet isInternetAvailable]){
                        
                        userAction = @"View Receipt";
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [[WebCalls sharedWebCalls] isTripArchived:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
                    }
                    else{
                        
                        [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                    }
                    
                }
                else{
                    
                    [self viewSavedReceipt];
                }
                
            }
            
            else if (btn.tag == 1009)//Edit Receipt
            {
                
                if ([mode isEqualToString:@"UPLOADED"]){
                    
                    if ([Internet isInternetAvailable]){
                        
                        userAction = @"Edit Receipt";
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [[WebCalls sharedWebCalls] isTripArchived:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
                    }
                    else{
                        
                        [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                    }
                    
                   
                }
                else{
                    
                    [self editSavedReceipt];
                }
            }
            else//Delete Receipt
            {
                
                if ([mode isEqualToString:@"UPLOADED"]){
                    
                    if ([Internet isInternetAvailable]){
                        
                        userAction = @"Delete Receipt";
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [[WebCalls sharedWebCalls] isTripArchived:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
                    }
                    else{
                        
                        [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                    }
                   
                  
                }
                else{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to delete this receipt?" delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Delete", nil];
                    alert.tag = 6547;
                    [alert show];
                }
            }
        }
   
    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1)
    {
        
        if (alertView.tag == 6547){
            
            [self deleteSavedReceipt];
        }
        else{
            
            NSDictionary *receiptDict = (NSDictionary*)[self.receiptsDataArray objectAtIndex:swipedIndex];
            [[WebCalls sharedWebCalls] deleteReceipt:[receiptDict valueForKey:@"id"] caller:self];
        }
    }
}

-(void)segmentControlValueChanged: (NSInteger) selectedSegment
{
     swipedIndex = -1;
   if (selectedSegment == 0)
    {
        mode = @"UPLOADED";
        [self filterUploadedReceipts];
        [self.tableView reloadData];
    }
    else
    {
        mode = @"SAVED";
        [self.unFilteredManagedObjects removeAllObjects];
        //[self.managedObjects removeAllObjects];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Receipts"];
        self.unFilteredManagedObjects = [[managedContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
        rowCountSavedReceipts = [ self.unFilteredManagedObjects count];
        
        [self filterSavedReceipts];
        
        UISegmentedControl * segment = (UISegmentedControl*)[self.parentViewController.view viewWithTag:3131];
        [segment setTitle:[NSString stringWithFormat:@"Saved For Later (%d)",rowCountSavedReceipts] forSegmentAtIndex:1];
        
       [self.tableView reloadData];
        
       
    }
   
    [self addRemoveNoReceiptsLable];
   
}
-(void) onUploadAllButton:(UIButton*)sender
{
   
    if(self.savedReceiptsDataArray.count > 0)
    {
        uploadAllButton = sender;
        
        [[self.parentViewController.view viewWithTag:1045] setHidden:NO];
        [uploadAllButton setHidden:YES];
        
        if(totalReceptsTobeUploaded == 0)
        {
            totalReceptsTobeUploaded = self.savedReceiptsDataArray.count;
             totalReceiptsUploaded = 0;
        }
        
        currentUploadingReceiptIndex = 0;
        
        
        NSDictionary* dict = (NSDictionary*)[self.savedReceiptsDataArray objectAtIndex:0];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *userName = [defaults valueForKey:@"USER_NAME"];
        
        UIImage *receiptImg = [self readImageFromDocumentsDirectory:[dict valueForKey:@"receipt"]];
        
        [[WebCalls sharedWebCalls] uploadAllReceipts:[dict valueForKey:@"trip_id"] receiptId:nil priceOtherCurrency:[dict valueForKey:@"foreign_currency_amount"] priceUSD:[dict valueForKey:@"usd"] currency:[dict valueForKey:@"foreign_currency"] type:[dict valueForKey:@"type"] description:[dict valueForKey:@"description"] userName:userName image:receiptImg date:[dict valueForKey:@"receipt_date"] caller:self];
    }
}

-(void) onUpload:(IndexedButton*)sender {
    
    NSIndexPath *path = sender.index;
    currentUploadingReceiptIndex = path.row;
    
    NSDictionary* dict = (NSDictionary*)[self.savedReceiptsDataArray objectAtIndex:path.row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults valueForKey:@"USER_NAME"];
    
    UIImage *receiptImg = [self readImageFromDocumentsDirectory:[dict valueForKey:@"receipt"]];
    
    [[WebCalls sharedWebCalls] uploadReceipt:[dict valueForKey:@"trip_id"] receiptId:nil priceOtherCurrency:[dict valueForKey:@"foreign_currency_amount"] priceUSD:[dict valueForKey:@"usd"] currency:[dict valueForKey:@"foreign_currency"] type:[dict valueForKey:@"type"] description:[dict valueForKey:@"description"] userName:userName image:receiptImg date:[dict valueForKey:@"receipt_date"] caller:self];
}


-(void)didGetWebResponse:(id)response forWebCall:(NSString *)webCall
{
    if (response)
    {
        if ([webCall isEqualToString:@"get_all_receipts"] || [webCall isEqualToString:@"get_user_receipts"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
                NSDictionary * receiptsDict = [response valueForKey:@"receipts"];
                if (receiptsDict)
                {
                    NSArray *receiptsArray = [receiptsDict valueForKey:@"Transaction"];
                    NSArray *usersArray = [receiptsDict valueForKey:@"User"];
                    if (receiptsArray.count > 0)
                    {
                        rowCountUploadedReceipts = receiptsArray.count;
//                        self.parentViewController.navigationItem.title = [NSString stringWithFormat:@"Receipts (%ld)",(long)rowCountUploadedReceipts];
                        
                         UISegmentedControl * segment = (UISegmentedControl*)[self.parentViewController.view viewWithTag:3131];
                        [segment setTitle:[NSString stringWithFormat:@"Uploaded (%ld)",(long)rowCountUploadedReceipts] forSegmentAtIndex:0];
                        
                        
                        [self.unFilteredReceiptsDataArray removeAllObjects];
                        [self.unFilteredReceiptsDataArray addObjectsFromArray:receiptsArray];
//                        [self.receiptsDataArray removeAllObjects];
//                        [self.receiptsDataArray addObjectsFromArray:receiptsArray];
                        [self.unFilteredUserDataArray removeAllObjects];
                        [self.unFilteredUserDataArray addObjectsFromArray:usersArray];
//                        [self.userDataArray removeAllObjects];
//                        [self.userDataArray addObjectsFromArray:usersArray];
                        [self filterUploadedReceipts];
                        [self.tableView reloadData];
                    }
                    [self addRemoveNoReceiptsLable];
                }
            }
        }
        else if([webCall isEqualToString:@"delete_receipt"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
                rowCountUploadedReceipts--;
//                self.parentViewController.navigationItem.title = [NSString stringWithFormat:@"Receipts (%ld)",(long)rowCountUploadedReceipts];
                
                UISegmentedControl * segment = (UISegmentedControl*)[self.parentViewController.view viewWithTag:3131];
                [segment setTitle:[NSString stringWithFormat:@"Uploaded (%ld)",(long)rowCountUploadedReceipts] forSegmentAtIndex:0];
                
                
                
                
                
//                if(self.receiptsDataArray.count > 0)
//                {
//                   [self.receiptsDataArray removeObjectAtIndex:swipedIndex]; 
//                }
                
                [rowHeights removeObjectAtIndex:swipedIndex];
                
                NSDictionary *receiptDict = (NSDictionary*)[self.receiptsDataArray objectAtIndex:swipedIndex];
                [self.unFilteredReceiptsDataArray removeObject:receiptDict];
                
                swipedIndex = -1;
                
                
                
//                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:swipedIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
               
                [self.tableView reloadData];
                
            }
            
            [self addRemoveNoReceiptsLable];
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
                    if ([userAction isEqualToString:@"View Receipt"])
                    {
                        [Internet addActivityIndicator];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                            NSURL * url = [NSURL URLWithString:[[self.receiptsDataArray objectAtIndex:swipedIndex] valueForKey:@"receipt"]];
                            NSData *imgData = [NSData dataWithContentsOfURL:url];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [Internet removeActivityIndicator];
                                
                                [self scrollViewWillBeginDragging:self.tableView];
                                [self.tableView setScrollEnabled:NO];
                                
                                
                                ReceiptImageViewController *cc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReceiptImage"];
                                cc.img = [UIImage imageWithData:imgData];
                               [self.parentViewController addChildViewController:cc];
                                cc.view.frame = CGRectMake(0, 0, self.parentViewController.view.frame.size.width, self.parentViewController.view.frame.size.height);
                                cc.view.alpha = 0.0;
                                [self.parentViewController.view addSubview:cc.view];
                                [cc didMoveToParentViewController:self.parentViewController];
                                [UIView animateWithDuration:0.5 animations:^{
                                    cc.view.alpha = 1.0;
                                }];
                            });
                            
                        });
                    }
                    else if ([userAction isEqualToString:@"Edit Receipt"])
                    {
                        self.navigationController.navigationBarHidden = YES;
                        AddReceiptViewController *ar = [self.storyboard instantiateViewControllerWithIdentifier:@"AddReceipt"];
                        ar.mode = @"EDIT";
                        ar.subMode = @"UPLOADED_RECEIPT";
                        ar.homeViewController = self.homeViewController;
                        ar.currrentReceipt = nil;
                        ar.receipt = (NSDictionary*)[self.receiptsDataArray objectAtIndex:swipedIndex];
                        [self.navigationController pushViewController:ar animated:YES];
                        swipedIndex = -1;
                    }
                    else if ([userAction isEqualToString:@"Delete Receipt"])
                    {
                        if (rowCountUploadedReceipts > 0)
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to delete this receipt?" delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Delete", nil];
                            [alert show];
                        }
                    }
                }
                else
                {
                    [self.navigationController popToViewController:self.homeViewController animated:NO];
                }
            }
        }
        else if([webCall isEqualToString:@"upload_receipt"])
        {
            NSString *status = [response valueForKey:@"status"];
            NSString *message = [[response valueForKey:@"messages"] objectAtIndex:0];
            if ([status isEqualToString:@"success"])
            {
                if(currentUploadingReceiptIndex >= 0)
                {
                    NSManagedObject *obj = [self.managedObjects objectAtIndex:currentUploadingReceiptIndex];
                    NSString *receiptName = [obj valueForKey:@"receipt"];
                    
                    [managedContext deleteObject:obj];
                    
                    NSError *error = nil;
                    if (![managedContext save:&error]) {
                        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                        return;
                    }
                    else{
                        
                        [self deleteImageFromDocumentsDirectory:receiptName];
                        [self segmentControlValueChanged:1]; //Refresh data arrays and table view.
                    }
                    
                    [[[UIAlertView alloc] initWithTitle:nil message:@"This receipt has been successfully uploaded." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                    currentUploadingReceiptIndex = -1;
                    
                    [self addRemoveNoReceiptsLable];
                }
                
            }
            else if ([message isEqualToString:@"Invalid trip ID or trip has been archived."])
            {
                  [[[UIAlertView alloc] initWithTitle:nil message:@"Receipt could not be uploaded because this trip has been archived." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"There was an error uploading the receipt. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                
                
                [[[UIAlertView alloc] initWithTitle:@"Error!" message:[NSString stringWithFormat:@"Debug Info:%@ + %@ + %@", status, message, [response description]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        }
        else if([webCall isEqualToString:@"upload_all_receipts"])
        {
            NSString *status = [response valueForKey:@"status"];
            NSString *message = [[response valueForKey:@"messages"] objectAtIndex:0];
            if ([status isEqualToString:@"success"])
            {
                if(currentUploadingReceiptIndex >= 0)
                {
                    NSManagedObject *obj = [self.managedObjects objectAtIndex:currentUploadingReceiptIndex];
                    NSString *receiptName = [obj valueForKey:@"receipt"];
                    
                    [managedContext deleteObject:obj];
                    
                    NSError *error = nil;
                    if (![managedContext save:&error]) {
                        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                        return;
                    }
                    else{
                        
                        [self deleteImageFromDocumentsDirectory:receiptName];
                        [self segmentControlValueChanged:1]; //Refresh data arrays and table view.
                        
                        if(self.savedReceiptsDataArray.count > 0)
                        {
                            totalReceiptsUploaded++;
                            [self showUploadAllProgress];
                            [self onUploadAllButton:uploadAllButton];
                        }
                        else{
                            
                            [[[UIAlertView alloc] initWithTitle:nil message:@"These receipts have been successfully uploaded ." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                            currentUploadingReceiptIndex = -1;
                            uploadAllButton = nil;
                            totalReceptsTobeUploaded = 0;
                            totalReceiptsUploaded = 0;
                            [self hideUploadAllProgress];
                            [self addRemoveNoReceiptsLable];
                        }
                    }
                    
                    
                }
                
            }
            else if ([message isEqualToString:@"Invalid trip ID or trip has been archived."])
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Receipt could not be uploaded because this trip has been archived." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Oops Something Went Wrong!" message:@"Please try again shortly." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                
                
               
            }
        }
        
    }
            
}

-(void) viewSavedReceipt{
    
    [Internet addActivityIndicator];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *imgName = [[self.savedReceiptsDataArray objectAtIndex:swipedIndex] valueForKey:@"receipt"];
        
        UIImage *image = [self readImageFromDocumentsDirectory:imgName];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [Internet removeActivityIndicator];
            
            [self scrollViewWillBeginDragging:self.tableView];
            [self.tableView setScrollEnabled:NO];
            
            
            ReceiptImageViewController *cc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReceiptImage"];
            cc.img = image;
            [self.parentViewController addChildViewController:cc];
            
            
            cc.view.frame = CGRectMake(0, 0, self.parentViewController.view.frame.size.width, self.parentViewController.view.frame.size.height);
            cc.view.alpha = 0.0;
            [self.parentViewController.view addSubview:cc.view];
            [cc didMoveToParentViewController:self.parentViewController];
            [UIView animateWithDuration:0.5 animations:^{
                cc.view.alpha = 1.0;
            }];
        });
        
    });
    
}

-(void) editSavedReceipt{
    
    self.navigationController.navigationBarHidden = YES;
    AddReceiptViewController *ar = [self.storyboard instantiateViewControllerWithIdentifier:@"AddReceipt"];
    ar.mode = @"EDIT";
    ar.subMode = @"SAVED_RECEIPT";
    ar.homeViewController = self.homeViewController;
    ar.currrentReceipt = (NSManagedObject*)[self.managedObjects objectAtIndex:swipedIndex];
    ar.receipt = (NSDictionary*)[self.savedReceiptsDataArray objectAtIndex:swipedIndex];
    [self.navigationController pushViewController:ar animated:YES];
    swipedIndex = -1;
    
}

-(void) deleteSavedReceipt{
    
    NSManagedObject *obj = [self.managedObjects objectAtIndex:swipedIndex];
    NSString *receiptName = [obj valueForKey:@"receipt"];
    [managedContext deleteObject:obj];
    
    NSError *error = nil;
    if (![managedContext save:&error]) {
        NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
        return;
    }
    else{
        
        rowCountSavedReceipts--;
       
        [self deleteImageFromDocumentsDirectory:receiptName];
        
        UISegmentedControl * segment = (UISegmentedControl*)[self.parentViewController.view viewWithTag:3131];
        [segment setTitle:[NSString stringWithFormat:@"Saved For Later (%d)",rowCountSavedReceipts] forSegmentAtIndex:1];
        
        [self.savedReceiptsDataArray removeObjectAtIndex:swipedIndex];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:swipedIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [rowHeights removeObjectAtIndex:swipedIndex];
        swipedIndex = -1;
        
        [self addRemoveNoReceiptsLable];
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(UIImage*) readImageFromDocumentsDirectory :(NSString*) imageName {
    
    NSString *filePath = [[self getDocumentsDirectorypath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
     UIImage *image = [UIImage imageWithData:pngData];
    
    return image;
}

-(void) deleteImageFromDocumentsDirectory:(NSString*) imageName {
    
     NSString *filePath = [[self getDocumentsDirectorypath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    
   if( [[NSFileManager defaultManager] fileExistsAtPath:filePath])
   {
       [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
   }
}

-(NSString*) getDocumentsDirectorypath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    return documentsPath;
}

-(void) addRemoveNoReceiptsLable {
   
    if ([mode isEqualToString:@"UPLOADED"]){
        
        if (self.unFilteredReceiptsDataArray.count <= 0)
        {
            
            [[self.tableView viewWithTag:98877] removeFromSuperview];
             [[self.tableView viewWithTag:98876] removeFromSuperview];
            
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(((self.tableView.frame.size.width - 200)/2) - 25 , (self.tableView.frame.size.height - 200)/2 - 100, 250, 200)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.numberOfLines = 10;
            lbl.text = @"There are not any uploaded receipts yet.\n\nAdd your first receipt by pressing on the \"Add a Receipt\" button on the home screen.";
            lbl.tag = 98876;
            lbl.font = [UIFont fontWithName:@"OpenSans-Semibold" size:17];
            lbl.textColor = [UIColor grayColor];
            
            [self.tableView addSubview:lbl];
            [self.tableView bringSubviewToFront:lbl];
        }
        else{
            
            [[self.tableView viewWithTag:98877] removeFromSuperview];
            [[self.tableView viewWithTag:98876] removeFromSuperview];
        }
       
        
    }
    else{
        
        if (self.unFilteredManagedObjects.count <= 0)
        {
            [[self.tableView viewWithTag:98876] removeFromSuperview];
            [[self.tableView viewWithTag:98877] removeFromSuperview];
            
            UIButton *uploadAllButton = (UIButton*)[self.parentViewController.view viewWithTag:3132];
            [uploadAllButton setHidden:YES];
            
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(((self.tableView.frame.size.width - 200)/2) - 25 , (self.tableView.frame.size.height - 200)/2 - 100, 250, 200)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.numberOfLines = 10;
            lbl.text = @"There are not any \"Saved for Later\" receipts yet.\n\nReceipts get stored here when an attempt to upload a receipt is made, but the Internet connection is too poor.";
            lbl.tag = 98877;
             lbl.font = [UIFont fontWithName:@"OpenSans-Semibold" size:17];
             lbl.textColor = [UIColor grayColor];
            
            [self.tableView addSubview:lbl];
            [self.tableView bringSubviewToFront:lbl];
        }
        else
        {
            
            [[self.tableView viewWithTag:98877] removeFromSuperview];
            [[self.tableView viewWithTag:98876] removeFromSuperview];
        }
       
    }
    
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

-(void)filterUploadedReceipts{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *tempUserArray1 = [[NSMutableArray alloc] init];
    NSMutableArray *tempReceiptDataArray1 = [[NSMutableArray alloc] init];
    
    NSMutableArray *tempUserArray2 = [[NSMutableArray alloc] init];
    NSMutableArray *tempReceiptDataArray2 = [[NSMutableArray alloc] init];
    
    NSMutableArray *tempUserArray3 = [[NSMutableArray alloc] init];
    NSMutableArray *tempReceiptDataArray3 = [[NSMutableArray alloc] init];
    
    if ([[defaults valueForKey:@"LOGGED_IN_USERTYPE"] isEqualToString:@"1"]){
        
        if([defaults valueForKey:@"Filter_Only_Mine"])
        {
            if([[defaults valueForKey:@"Filter_Only_Mine"] boolValue])
            {
                
                
                for( int i = 0; i < self.unFilteredUserDataArray.count; i++){
                    
                    NSDictionary * user = [self.unFilteredUserDataArray objectAtIndex:i];
                    NSString *name;
                    
                    if ([[user valueForKey:@"middle_name"] isEqualToString:@""])
                    {
                        name = [NSString stringWithFormat:@"%@ %@",[user valueForKey:@"first_name"],[user valueForKey:@"last_name"]];
                    }
                    else
                    {
                        name = [NSString stringWithFormat:@"%@ %@ %@",[user valueForKey:@"first_name"],[user valueForKey:@"middle_name"],[user valueForKey:@"last_name"]];
                    }
                    
                    
                    
                    NSString *userName = [NSString stringWithFormat:@"%@",[defaults valueForKey:@"USER_NAME"] ];
                    
                    if ([name isEqualToString:userName])
                    {
                        [tempUserArray1 addObject:user];
                        [tempReceiptDataArray1 addObject:[self.unFilteredReceiptsDataArray objectAtIndex:i]];
                    }
                    
                }
            }
            else{
                
                tempReceiptDataArray1 = self.unFilteredReceiptsDataArray;
                tempUserArray1 = self.unFilteredUserDataArray;
            }
        }
        else{
            
            tempReceiptDataArray1 = self.unFilteredReceiptsDataArray;
            tempUserArray1 = self.unFilteredUserDataArray;
        }
    }
    else{
        
        tempReceiptDataArray1 = self.unFilteredReceiptsDataArray;
        tempUserArray1 = self.unFilteredUserDataArray;
    }
    
    
    
    if([defaults valueForKey:@"Filter_All_Dates"])
        {
            if(![[defaults valueForKey:@"Filter_All_Dates"] boolValue]){
                
                for( int i = 0; i < tempReceiptDataArray1.count; i++){
                    
                    NSDictionary * receipt = [tempReceiptDataArray1 objectAtIndex:i];
                    
                    NSDate *receiptDate = [self dateFromString:[receipt valueForKey:@"receipt_date"] inputFormat:@"yyyy-MM-dd hh:mm a"];
                    NSDate *fromDate = [self dateFromString:[defaults valueForKey:@"Filter_From_Date"] inputFormat:@"MMM dd, yyyy"];
                    NSDate *untilDate = [self dateFromString:[defaults valueForKey:@"Filter_Until_Date"] inputFormat:@"MMM dd, yyyy"];
                    
                    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                    dayComponent.day = 1;
                    
                    NSCalendar *theCalendar = [NSCalendar currentCalendar];
                    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:untilDate options:0];
                    
                   
                    
                    if([receiptDate timeIntervalSinceDate:fromDate] >= 0 && [nextDate timeIntervalSinceDate:receiptDate] >= 0){
                        
                        [tempReceiptDataArray2 addObject:receipt];
                        [tempUserArray2 addObject:[tempUserArray1 objectAtIndex:i]];
                    }
                }
            }
            else{
                
                tempReceiptDataArray2 = tempReceiptDataArray1;
                tempUserArray2 = tempUserArray1;
            }
        }
        else{
            
            tempReceiptDataArray2 = tempReceiptDataArray1;
            tempUserArray2 = tempUserArray1;
        }
        
    
    
    
        if([defaults valueForKey:@"Filter_Categories"])
        {
            NSMutableArray *categoryFilters = (NSMutableArray*)[defaults valueForKey:@"Filter_Categories"];
            
            if([categoryFilters count] == 1 && [[categoryFilters objectAtIndex:0] isEqualToString:@"All"])
            {
                tempReceiptDataArray3 = tempReceiptDataArray2;
                tempUserArray3 = tempUserArray2;
            }
            else{
                
                for(int i = 0; i < tempReceiptDataArray2.count; i++)
                {
                     NSDictionary * receipt = [tempReceiptDataArray2 objectAtIndex:i];
                     NSString *receiptCategory = [receipt valueForKey:@"type"];
                    
                     if([categoryFilters containsObject:receiptCategory])
                     {
                         [tempReceiptDataArray3 addObject:receipt];
                         [tempUserArray3 addObject:[tempUserArray2 objectAtIndex:i]];
                     }
                }
            }
                
        }
        else{
            
            tempReceiptDataArray3 = tempReceiptDataArray2;
            tempUserArray3 = tempUserArray2;
        }
        
    
    
    
    self.receiptsDataArray = tempReceiptDataArray3;
    self.userDataArray = tempUserArray3;
    
   
}

-(void)filterSavedReceipts{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempSavedReceiptDataArray1 = [[NSMutableArray alloc] init];
    NSMutableArray *tempSavedReceiptDataArray2 = [[NSMutableArray alloc] init];
    
    
    if([defaults valueForKey:@"Filter_All_Dates"])
        {
            if(![[defaults valueForKey:@"Filter_All_Dates"] boolValue]){
                
                for( int i = 0; i < self.unFilteredManagedObjects.count; i++){
                    
                    NSDictionary * receipt = [self.unFilteredManagedObjects objectAtIndex:i];
                    
                    NSDate *receiptDate = [self dateFromString:[receipt valueForKey:@"date"] inputFormat:@"yyyy-MM-dd hh:mm a"];
                    NSDate *fromDate = [self dateFromString:[defaults valueForKey:@"Filter_From_Date"] inputFormat:@"MMM dd, yyyy"];
                    NSDate *untilDate = [self dateFromString:[defaults valueForKey:@"Filter_Until_Date"] inputFormat:@"MMM dd, yyyy"];
                    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                    dayComponent.day = 1;
                    
                    NSCalendar *theCalendar = [NSCalendar currentCalendar];
                    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:untilDate options:0];
                    
                    if([receiptDate timeIntervalSinceDate:fromDate] >= 0 && [nextDate timeIntervalSinceDate:receiptDate] >= 0){
                        
                        [tempSavedReceiptDataArray1 addObject:receipt];
                        
                    }
                }
            }
            else{
                tempSavedReceiptDataArray1 = self.unFilteredManagedObjects;
                
            }
            
            
        }
        else{
            tempSavedReceiptDataArray1 = self.unFilteredManagedObjects;
            
        }
        
    
    if([defaults valueForKey:@"Filter_Categories"])
        {
            NSMutableArray *categoryFilters = (NSMutableArray*)[defaults valueForKey:@"Filter_Categories"];
            
            if([categoryFilters count] == 1 && [[categoryFilters objectAtIndex:0] isEqualToString:@"All"])
            {
                tempSavedReceiptDataArray2 =  tempSavedReceiptDataArray1;
               
            }
            else{
                
                for(int i = 0; i < tempSavedReceiptDataArray1.count; i++)
                {
                    NSDictionary * receipt = [tempSavedReceiptDataArray1 objectAtIndex:i];
                    NSString *receiptCategory = [receipt valueForKey:@"type"];
                    
                    if([categoryFilters containsObject:receiptCategory])
                    {
                        [tempSavedReceiptDataArray2 addObject:receipt];
                        
                    }
                }
            }
            
        }
        else{
             tempSavedReceiptDataArray2 =  tempSavedReceiptDataArray1;
        }
        
        
    
    
    self.managedObjects = tempSavedReceiptDataArray2;
    
    [self.savedReceiptsDataArray removeAllObjects];
    if (self.managedObjects.count > 0)
    {
        for (NSManagedObject * receipt in self.managedObjects) {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            [dict setValue:[receipt valueForKey:@"receipt_description"] forKey:@"description"];
            [dict setValue:[receipt valueForKey:@"foreign_currency"] forKey:@"foreign_currency"];
            [dict setValue:[receipt valueForKey:@"foreign_currency_amount"] forKey:@"foreign_currency_amount"];
            [dict setValue:[receipt valueForKey:@"receipt"] forKey:@"receipt"];
            [dict setValue:[receipt valueForKey:@"trip_id"] forKey:@"trip_id"];
            [dict setValue:[receipt valueForKey:@"type"] forKey:@"type"];
            [dict setValue:[receipt valueForKey:@"usd"] forKey:@"usd"];
            [dict setValue:[receipt valueForKey:@"date"] forKey:@"receipt_date"];
            
            [self.savedReceiptsDataArray addObject:dict];
        }
    }
    
}

-(void) showUploadProgress:(long long)bytesWritten remaining:(long long)totalBytes
{
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentUploadingReceiptIndex inSection:0]];
    
    [[cell.contentView viewWithTag: 1026] setHidden:NO];
    [[cell.contentView viewWithTag: 1024] setHidden:YES];
    
    UIProgressView * progress = (UIProgressView*)[cell.contentView viewWithTag: 1026];
    
    double p = (double)bytesWritten/(double)totalBytes;
    [progress setProgress:p animated:YES];
}
-(void) hideUploadProgress
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentUploadingReceiptIndex inSection:0]];
    [[cell.contentView viewWithTag: 1026] setHidden:YES];
    [[cell.contentView viewWithTag: 1024] setHidden:NO];
}

-(void) showUploadAllProgress
{
   
    UIProgressView * progress = (UIProgressView*)[self.parentViewController.view viewWithTag:1045];
    double p = (double)totalReceiptsUploaded/(double)totalReceptsTobeUploaded;
    [progress setProgress:p animated:YES];
}
-(void) hideUploadAllProgress
{
    [[self.parentViewController.view viewWithTag:1045] setHidden:YES];
    [uploadAllButton setHidden:NO];
     totalReceptsTobeUploaded = 0;
     totalReceiptsUploaded = 0;
}

@end
