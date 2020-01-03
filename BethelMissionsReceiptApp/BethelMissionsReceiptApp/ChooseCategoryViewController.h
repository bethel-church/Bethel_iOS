//
//  ChooseCategoryViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/11/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CategoryDelegate
-(void) setCategory:(NSString*)category;
@end
@interface ChooseCategoryViewController : UIViewController
@property(weak, nonatomic) id <CategoryDelegate> categoryDelegate;
@end
