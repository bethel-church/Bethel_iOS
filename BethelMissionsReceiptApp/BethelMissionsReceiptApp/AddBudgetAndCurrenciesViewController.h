//
//  AddBudgetAndCurrenciesViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/7/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectCurrenciesViewController.h"
#import "WebCalls.h"
@interface AddBudgetAndCurrenciesViewController : UIViewController<UITextFieldDelegate,SelectedCurrenciesDelegate,WebResponseClient>
@property(nonatomic,strong) NSString * userName;
@end
