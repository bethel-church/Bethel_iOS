//
//  CustomTableViewCell.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/15/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    // Convert the point to the target view's coordinate system.
    // The target view isn't necessarily the immediate subview
    CGPoint pointForTargetView = [[self.contentView viewWithTag:1009] convertPoint:point fromView:self];
    
    if (CGRectContainsPoint([self.contentView viewWithTag:1009].bounds, pointForTargetView)) {
        
        // The target view may have its view hierarchy,
        // so call its hitTest method to return the right hit-test view
        return [[self.contentView viewWithTag:1009] hitTest:pointForTargetView withEvent:event];
    }
    
    pointForTargetView = [[self.contentView viewWithTag:1008] convertPoint:point fromView:self];
    
    if (CGRectContainsPoint([self.contentView viewWithTag:1008].bounds, pointForTargetView)) {
        
        // The target view may have its view hierarchy,
        // so call its hitTest method to return the right hit-test view
        return [[self.contentView viewWithTag:1008] hitTest:pointForTargetView withEvent:event];
    }
    
    pointForTargetView = [[self.contentView viewWithTag:10010] convertPoint:point fromView:self];
    
    if (CGRectContainsPoint([self.contentView viewWithTag:10010].bounds, pointForTargetView)) {
        
        // The target view may have its view hierarchy,
        // so call its hitTest method to return the right hit-test view
        return [[self.contentView viewWithTag:10010] hitTest:pointForTargetView withEvent:event];
    }
    
    
    return [super hitTest:point withEvent:event];
}

@end
