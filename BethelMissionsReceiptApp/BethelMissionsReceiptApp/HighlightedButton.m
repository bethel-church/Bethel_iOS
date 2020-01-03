//
//  HighlightedButton.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 12/08/16.
//  Copyright © 2016 Calico. All rights reserved.
//

#import "HighlightedButton.h"

@implementation HighlightedButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) setHighlighted:(BOOL)highlighted
{
    if(highlighted) {
        
        self.backgroundColor = [UIColor colorWithRed:44/256.0 green:76/256.0 blue:83/256.0 alpha:1];
    
    } else {
       
        self.backgroundColor = [UIColor colorWithRed:44/256.0 green:76/256.0 blue:83/256.0 alpha:0.8];
        
        // self.backgroundColor = [UIColor colorWithRed:68/256.0 green:88/256.0 blue:92/256.0 alpha:0.8];
    }
    [super setHighlighted:NO];
}

-(void) setSelected:(BOOL)selected
{
    if(selected) {
        self.backgroundColor = [UIColor colorWithRed:44/256.0 green:76/256.0 blue:83/256.0 alpha:1];
        
    } else {
        
        self.backgroundColor = [UIColor colorWithRed:44/256.0 green:76/256.0 blue:83/256.0 alpha:0.8];
       // self.backgroundColor = [UIColor colorWithRed:68/256.0 green:88/256.0 blue:92/256.0 alpha:0.8];
    }
    [super setHighlighted:NO];
}
@end
