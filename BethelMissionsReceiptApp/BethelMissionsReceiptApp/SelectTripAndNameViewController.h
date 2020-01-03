//
//  SelectTripViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/4/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectTripDelegate
@optional
-(void) selectedTrip:(NSString*)trip;
@end
@interface SelectTripAndNameViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) id <SelectTripDelegate> delegate;
@property (strong, nonatomic) NSString *mode; // Trip_Name or Member_Name
@property (nonatomic,strong) NSMutableArray *tripsArray;
@property (nonatomic,strong) NSMutableArray *usersArray;
@end
