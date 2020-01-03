//
//  UserReceiptsListTableViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 25/05/16.
//  Copyright © 2016 Calico. All rights reserved.
//

#import "UserReceiptsListTableViewController.h"
#import "CustomTableViewCell.h"
#import "ReceiptImageViewController.h"
#import "AddReceiptViewController.h"
#import "FiltersViewController.h"
@interface UserReceiptsListTableViewController (){
    
    CGFloat btnheight;
    NSMutableArray *rowHeights;
    NSInteger swipedIndex;
    NSInteger rowCountUploadedReceipts;
    NSString *userAction;
    NSString *userName;
}

@property (nonatomic,strong) NSMutableArray* receiptsDataArray;
@property (nonatomic,strong) NSMutableArray* userDataArray;
@property (nonatomic,strong) NSMutableArray* unFilteredReceiptsDataArray;
@property (nonatomic,strong) NSMutableArray* unFilteredUserDataArray;

@end

@implementation UserReceiptsListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    rowHeights = [[NSMutableArray alloc] init];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.receiptsDataArray = [[NSMutableArray alloc] init];
    self.userDataArray = [[NSMutableArray alloc] init];
    self.unFilteredReceiptsDataArray = [[NSMutableArray alloc] init];
    self.unFilteredUserDataArray = [[NSMutableArray alloc] init];
    
    swipedIndex = -1;
    
    rowCountUploadedReceipts = [self.receiptsDataArray count];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    backBarButtonItem.imageInsets = UIEdgeInsetsMake(3, -10, -3, 0);
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    UIButton *fButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 76, 24)];
    [fButton setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [fButton setImage:[UIImage imageNamed:@"filter-pressed"] forState:UIControlStateHighlighted];
    [fButton setImage:[UIImage imageNamed:@"filter-pressed"] forState:UIControlStateSelected];
    [fButton addTarget:self action:@selector(onFilter) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *filterButtonItem = [[UIBarButtonItem alloc] initWithCustomView:fButton];
    self.navigationItem.rightBarButtonItem = filterButtonItem;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:16],NSFontAttributeName,
      [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
   
    
   
    NSString * middleName = [self.user valueForKey:@"middle_name"];
    if(![middleName isEqualToString:@""])
    {
        userName = [NSString stringWithFormat:@"%@ %@ %@",[self.user valueForKey:@"first_name"],[self.user valueForKey:@"middle_name"],[self.user valueForKey:@"last_name"]];
    }
    else{
        
        userName = [NSString stringWithFormat:@"%@ %@",[self.user valueForKey:@"first_name"],[self.user valueForKey:@"last_name"]];
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%d)",userName,rowCountUploadedReceipts] ;
    
     [self.tableView reloadData];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[WebCalls sharedWebCalls] getReceipts:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] userName:userName caller:self];
    
}

-(void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)onFilter
{
    
    FiltersViewController *fl = [self.storyboard instantiateViewControllerWithIdentifier:@"Filters"];
    
    fl.mode = @"Leader_Partial";
   
    [self.navigationController pushViewController:fl animated:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // self.navigationController.navigationBarHidden = YES;
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeHoveringTotal];
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
    
    return self.receiptsDataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *receiptDict = (NSDictionary*)[self.receiptsDataArray objectAtIndex:indexPath.row];
    NSDictionary *userDict = (NSDictionary*)[self.userDataArray objectAtIndex:indexPath.row];
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserReceiptCell" forIndexPath:indexPath];
    
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
    NSLog(@"%@",name);
    if ([nameLabel.text isEqualToString:name])
    {
        nameLabel.text = @"Me";
    }
    
    dateTimeLable.text = [self formatDate:[receiptDict valueForKey:@"created"]];
    typeLabel.text = [receiptDict valueForKey:@"type"];
    descriptionLabel.text = [receiptDict valueForKey:@"description"];
    priceLabel.text = [NSString stringWithFormat:@"$%.2f",[[receiptDict valueForKey:@"usd"] doubleValue]] ;
    
    cell.contentView.clipsToBounds = YES;
    return cell;
}

-(NSString*)formatDate:(NSString*)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSDate *date = [formatter dateFromString:dateString];
    
    [formatter setDateFormat:@"M/d/yy hh:mm a"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    return [formatter stringFromDate:date];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    
}

-(void)viewDidLayoutSubviews
{
    for (int i = 0 ; i < rowCountUploadedReceipts; i++)
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
    NSLog(@"%f",UITableViewAutomaticDimension);
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
    if ([Internet isInternetAvailable])
    {
        if (swipedIndex != -1)
        {
            
            
            if (btn.tag == 1008)//View Receipt
            {
                
                userAction = @"View Receipt";
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [[WebCalls sharedWebCalls] isTripArchived:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
            }
            
            else if (btn.tag == 1009)//Edit Receipt
            {
                userAction = @"Edit Receipt";
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [[WebCalls sharedWebCalls] isTripArchived:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
            }
            else//Delete Receipt
            {
                userAction = @"Delete Receipt";
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [[WebCalls sharedWebCalls] isTripArchived:[[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"] caller:self];
            }
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSDictionary *receiptDict = (NSDictionary*)[self.receiptsDataArray objectAtIndex:swipedIndex];
        [[WebCalls sharedWebCalls] deleteReceipt:[receiptDict valueForKey:@"id"] caller:self];
        
    }
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
                         self.navigationItem.title = [NSString stringWithFormat:@"%@ (%d)",userName,rowCountUploadedReceipts] ;
                        
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
                    [self addHoveringTotal];
                    
                    
                    
                }
            }
        }
        else if([webCall isEqualToString:@"delete_receipt"])
        {
            NSString *status = [response valueForKey:@"status"];
            if ([status isEqualToString:@"success"])
            {
                rowCountUploadedReceipts--;
                self.navigationItem.title = [NSString stringWithFormat:@"%@ (%d)",userName,rowCountUploadedReceipts] ;
                [self.receiptsDataArray removeObjectAtIndex:swipedIndex];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:swipedIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [rowHeights removeObjectAtIndex:swipedIndex];
                swipedIndex = -1;
                
                [self addRemoveNoReceiptsLable];
                [self addHoveringTotal];
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
                                [self addChildViewController:cc];
                                cc.view.frame = CGRectMake(self.view.frame.origin.x, self.tableView.contentOffset.y, self.view.frame.size.width, self.view.frame.size.height);
                                cc.view.alpha = 0.0;
                                [self.view addSubview:cc.view];
                                [cc didMoveToParentViewController:self];
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
        
        
    }
    
    
}

-(void) addRemoveNoReceiptsLable {
    
   if (self.unFilteredReceiptsDataArray.count <= 0)
        {
            [[self.tableView viewWithTag:98876] removeFromSuperview];
            
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(((self.tableView.frame.size.width - 200)/2) - 25 , (self.tableView.frame.size.height - 50)/2, 250, 50)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.numberOfLines = 10;
            lbl.text = @"This trip member has not added any receipts yet.";
            lbl.tag = 98876;
            lbl.font = [UIFont fontWithName:@"OpenSans-Semibold" size:17];
            lbl.textColor = [UIColor grayColor];
            
            [self.tableView addSubview:lbl];
            [self.tableView bringSubviewToFront:lbl];
        }
        else{
            
           [[self.tableView viewWithTag:98876] removeFromSuperview];
        }
        
}

-(void) addHoveringTotal{
    
    AppDelegate * delg = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIWindow *appWindow = [delg window];
    
    [[appWindow viewWithTag:213141] removeFromSuperview];
    [[appWindow viewWithTag:213142] removeFromSuperview];
    
    //total spent
    UIView * hover = [[UIView alloc] initWithFrame:CGRectMake(10.0, [[UIScreen mainScreen] bounds].size.height - 60, 100, 50)];
    hover.backgroundColor = [UIColor colorWithRed:41/256.0 green:75/256.0 blue:82/256.0 alpha:1.0];
    hover.tag = 213141;
    
    hover.layer.cornerRadius = 5.0;
    hover.clipsToBounds = YES;
    hover.alpha = 0.95;
    
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
    
    
    //Filtered Spent
    if(self.receiptsDataArray.count < self.unFilteredReceiptsDataArray.count){
        
        UIView * hover1 = [[UIView alloc] initWithFrame:CGRectMake(120.0, [[UIScreen mainScreen] bounds].size.height - 60, 100, 50)];
        hover1.backgroundColor = [UIColor lightGrayColor];
        hover1.tag = 213142;
        
        hover1.layer.cornerRadius = 5.0;
        hover1.clipsToBounds = YES;
        
        hover1.alpha = 0.95;
        
        UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 100, 30)];
        amountLabel.textAlignment = NSTextAlignmentCenter;
        amountLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20];
        amountLabel.text = [NSString stringWithFormat:@"$%0.02f",[self calculateFilterTotal]];
        amountLabel.textColor = [UIColor colorWithRed:46/256.0 green:78/256.0 blue:85/256.0 alpha:1.0];
        [hover1 addSubview:amountLabel];
        
        UILabel *totalSpentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 27, 100, 20)];
        totalSpentLabel.textAlignment = NSTextAlignmentCenter;
        totalSpentLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:11];
        totalSpentLabel.text = @"Filter Total";
        totalSpentLabel.textColor = [UIColor colorWithRed:46/256.0 green:78/256.0 blue:85/256.0 alpha:1.0];
        [hover1 addSubview:totalSpentLabel];
        
        [appWindow addSubview:hover1];
    }
}

-(double) calculateTotalSpent
{
    double total = 0.0;
    
    for(NSDictionary * dict in self.unFilteredReceiptsDataArray){
        
        total += [[dict valueForKey:@"usd"] doubleValue];
    }
    return total;
}

-(double) calculateFilterTotal
{
    double total = 0.0;
    
    for(NSDictionary * dict in self.receiptsDataArray){
        
        total += [[dict valueForKey:@"usd"] doubleValue];
    }
    return total;
}

-(void) removeHoveringTotal{
    
    AppDelegate * delg = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIWindow *appWindow = [delg window];
    
    [[appWindow viewWithTag:213141] removeFromSuperview];
    [[appWindow viewWithTag:213142] removeFromSuperview];
}

-(void)filterUploadedReceipts{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *tempUserArray1 = [[NSMutableArray alloc] init];
    NSMutableArray *tempReceiptDataArray1 = [[NSMutableArray alloc] init];
    
    NSMutableArray *tempUserArray2 = [[NSMutableArray alloc] init];
    NSMutableArray *tempReceiptDataArray2 = [[NSMutableArray alloc] init];
    
    NSMutableArray *tempUserArray3 = [[NSMutableArray alloc] init];
    NSMutableArray *tempReceiptDataArray3 = [[NSMutableArray alloc] init];
    
   
        
    tempReceiptDataArray1 = self.unFilteredReceiptsDataArray;
    tempUserArray1 = self.unFilteredUserDataArray;
    
    
    
    
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

-(NSDate*) dateFromString:(NSString*)string inputFormat:(NSString*)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter dateFromString:string];
}
@end
