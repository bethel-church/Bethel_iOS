//
//  WebCalls.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/8/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define bethelMissionsBaseURL @"http://betheltripreceipts.com/services/"
//#define bethelMissionsBaseURL @"http://ec2-35-177-203-210.eu-west-2.compute.amazonaws.com/services/"

#import "Internet.h"
@protocol WebResponseClient
-(void) didGetWebResponse:(id)response forWebCall:(NSString*)webCall;
@optional
-(void) networkIssueHandler;
-(void) showUploadProgress:(long long)bytesWritten remaining:(long long)totalBytes;
-(void) hideUploadProgress;
-(void) hideUploadAllProgress;
@end

@interface WebCalls : NSObject
+(WebCalls*)sharedWebCalls;
-(void) getCurrencies;
-(void)getTripList:(NSString*) category caller:(id)caller ;
-(void)login:(NSString *)tripId passcode:(NSString*)passcode caller:(id)caller;
-(void)getTripBudget:(NSString*)tripId caller:(id)caller;
-(void)setTripBudget:(NSString*)tripId tripBudget:(NSString*)budget caller:(id)caller;
-(void)getTripCurrencies:(NSString*)tripId caller:(id)caller;
-(void)setTripCurrencies:(NSString*)tripId currencies:(NSArray*)currencies caller:(id)caller;
-(void)addUpdateReceipt:(NSString*)tripId receiptId:(NSString*)receiptId priceOtherCurrency:(NSString*)priceOtherCurrency priceUSD:(NSString*)priceUSD  currency:(NSString*)currrency type:(NSString*)type description:(NSString*)description userName:(NSString*)userName image:(UIImage*)img date:(NSString*)date caller:(id)caller;
-(void)getReceipts:(NSString*)tripId userName:(NSString*)name caller:(id)caller;
-(void)deleteReceipt:(NSString*)receiptId caller:(id)caller;
-(void) isTripArchived:(NSString*) tripId caller:(id)caller;
+(NSDictionary*)currencyFullNamesDictionary;
-(void)uploadReceipt:(NSString*)tripId receiptId:(NSString*)receiptId priceOtherCurrency:(NSString*)priceOtherCurrency priceUSD:(NSString*)priceUSD  currency:(NSString*)currrency type:(NSString*)type description:(NSString*)description userName:(NSString*)userName image:(UIImage*)img date:(NSString*)date caller:(id)caller;
-(void)uploadAllReceipts:(NSString*)tripId receiptId:(NSString*)receiptId priceOtherCurrency:(NSString*)priceOtherCurrency priceUSD:(NSString*)priceUSD  currency:(NSString*)currrency type:(NSString*)type description:(NSString*)description userName:(NSString*)userName image:(UIImage*)img date:(NSString*)date caller:(id)caller;
-(void) getStudentBudgetDetails:(NSString*)tripId userName:(NSString*)userName  caller:(id)caller;
-(void) getUserDetails:(NSString*)tripId caller:(id)caller;
@end
