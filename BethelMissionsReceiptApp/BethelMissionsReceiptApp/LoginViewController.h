//
//  LoginViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/4/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectTripAndNameViewController.h"
#import "HomeViewController.h"
#import "WebCalls.h"
@interface LoginViewController : UIViewController<UITextFieldDelegate,SelectTripDelegate,WebResponseClient>

@end
