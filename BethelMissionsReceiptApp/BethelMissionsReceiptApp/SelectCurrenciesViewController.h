//
//  SelectCurrenciesViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/9/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebCalls.h"
@protocol SelectedCurrenciesDelegate
@optional
-(void) setCurrencies:(NSMutableArray*)currencies;
@end
@interface SelectCurrenciesViewController : UIViewController<WebResponseClient>
@property (weak,nonatomic) id <SelectedCurrenciesDelegate> delegate;
@property (strong,nonatomic) NSMutableArray *selectedCurrencies;
@property (assign, nonatomic) BOOL animatedPop;
@end
