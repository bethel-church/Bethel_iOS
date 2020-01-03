//
//  CustomContentView.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/15/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "CustomContentView.h"

@implementation CustomContentView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    // Convert the point to the target view's coordinate system.
    // The target view isn't necessarily the immediate subview
    CGPoint pointForTargetView = [[self viewWithTag:1009] convertPoint:point fromView:self];
    
    if (CGRectContainsPoint([self viewWithTag:1009].bounds, pointForTargetView)) {
        
        // The target view may have its view hierarchy,
        // so call its hitTest method to return the right hit-test view
        return [[self viewWithTag:1009] hitTest:pointForTargetView withEvent:event];
    }
    
    return [super hitTest:point withEvent:event];
}
@end
