//
//  ReceiptImageViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/11/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "ReceiptImageViewController.h"

@interface ReceiptImageViewController ()
- (IBAction)onClose:(id)sender;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;


@end

@implementation ReceiptImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.view.backgroundColor = [UIColor colorWithRed:40/256.0 green:40/256.0 blue:40/256.0 alpha:0.9];
    self.imageView.image = self.img;
   
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.imageView setFrame:CGRectMake(0, 0, self.imageView.frame.size.width, self.img.size.height)];
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    //[self.scrollView setContentSize:self.img.size];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClose:(id)sender {
    
    if ([[self.view superview] isKindOfClass:[UITableView class]])
    {
        UITableView * tableView = (UITableView*)[self.view superview];
        [tableView setScrollEnabled:YES];
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self willMoveToParentViewController:nil];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        });
    }];
}
- (IBAction)onImageTap:(id)sender {
    [self onClose:sender];
}
@end
