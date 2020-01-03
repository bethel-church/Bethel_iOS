//
//  Internet.h
//  TwoFitApp
//
//  Created by Vivek Bhuria on 12/24/14.
//  Copyright (c) 2014 vDelve. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Internet : NSObject
+(void) addActivityIndicator;
+(void) removeActivityIndicator;
+(BOOL) isInternetAvailable;
@end
