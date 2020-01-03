//
//  ChooseCurrencyViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/10/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CurrencyDelegate
-(void) setCurrency:(NSString*)currency;
@end
@interface ChooseCurrencyViewController : UIViewController
@property (weak,nonatomic) id <CurrencyDelegate> currencyDelegate;
@end
