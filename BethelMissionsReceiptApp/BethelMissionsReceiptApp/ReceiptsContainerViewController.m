//
//  ReceiptsContainerViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 10/05/16.
//  Copyright © 2016 Calico. All rights reserved.
//

#import "ReceiptsContainerViewController.h"
#import "ViewReceiptsTableViewController.h"
@interface ReceiptsContainerViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
- (IBAction)onUploadAll:(id)sender;
- (IBAction)onSegmentValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *uploadAllButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@end

@implementation ReceiptsContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ViewReceiptsTableViewController *vr = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewReceipts"];
    
    vr.homeViewController = self.homeViewController;
    
    [self addChildViewController:vr];
    vr.view.frame = CGRectMake(self.view.frame.origin.x, self.segmentControl.frame.origin.y + self.segmentControl.frame.size.height + 10, self.view.frame.size.width, self.view.frame.size.height - (self.segmentControl.frame.origin.y + self.segmentControl.frame.size.height + 10));
    
    [self.view addSubview:vr.view];
    [vr didMoveToParentViewController:self];
    
    self.delegate = vr;
    
    self.progress.layer.cornerRadius = 3.0;
    self.progress.clipsToBounds = YES;
}

//-(void) viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    [self setTableViewFrame];
    
    
//}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
      [self setTableViewFrame];
}

-(void) setTableViewFrame
{
    
    UIViewController * vc = (UIViewController*)[self.childViewControllers objectAtIndex:0];
    
    if (self.segmentControl.selectedSegmentIndex == 0) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            vc.view.frame = CGRectMake(self.view.frame.origin.x, self.segmentControl.frame.origin.y + self.segmentControl.frame.size.height + 10, self.view.frame.size.width, self.view.frame.size.height - (self.segmentControl.frame.origin.y + self.segmentControl.frame.size.height + 10));
           
        }];
        
    }
    else{
        
         [UIView animateWithDuration:0.5 animations:^{
             
             vc.view.frame = CGRectMake(self.view.frame.origin.x, self.uploadAllButton.frame.origin.y + self.uploadAllButton.frame.size.height + 8, self.view.frame.size.width, self.view.frame.size.height - (self.uploadAllButton.frame.origin.y + self.uploadAllButton.frame.size.height + 8));
         }];
    }
    
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

- (IBAction)onUploadAll:(id)sender {
    
    [self.delegate onUploadAllButton:(UIButton*)sender];
}

- (IBAction)onSegmentValueChanged:(id)sender {
    
    [self setTableViewFrame];
     UISegmentedControl * seg = (UISegmentedControl*)sender;
    [self.delegate segmentControlValueChanged:seg.selectedSegmentIndex];
}
@end
