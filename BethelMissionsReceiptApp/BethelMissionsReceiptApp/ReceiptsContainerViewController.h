//
//  ReceiptsContainerViewController.h
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 10/05/16.
//  Copyright © 2016 Calico. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SegmentAndUploadButtonDelegate
@optional
-(void) segmentControlValueChanged: (NSInteger) selectedSegment;
-(void) onUploadAllButton:(UIButton*)sender;
@end
@interface ReceiptsContainerViewController : UIViewController
@property (nonatomic,weak) UIViewController *homeViewController;
@property (nonatomic, weak) id <SegmentAndUploadButtonDelegate> delegate;
@end
