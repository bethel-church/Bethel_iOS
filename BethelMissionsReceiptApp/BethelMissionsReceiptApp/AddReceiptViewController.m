//
//  AddReceiptViewController.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/10/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "AddReceiptViewController.h"
#import "ReceiptImageViewController.h"


#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]

@interface AddReceiptViewController ()
{
    double diff;
    FirstCameraOverlayViewController * fo;
    SecondCameraOverlayViewController * so;
    HelpScreenOverlayViewController *ho;
    NSString *selectedCurrency;
    BOOL receiptImageUpdated;// Only for EDIT mode, to figure out if image has been updated and hence does it need to be uploaded again.
    NSManagedObjectContext *managedContext;
    //NSManagedObject *currrentReceipt;
    NSDate *selectedDate;
   
}
@property (strong, nonatomic) IBOutlet UIControl *bottomHalfView;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UIButton *takePhotoButton;
- (IBAction)onTakePhoto:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *currencyLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateOfSaleLabel;

@property (weak, nonatomic) IBOutlet UITextField *dateTextField;

@property (strong, nonatomic) IBOutlet UITextField *priceTextField;
@property (strong, nonatomic) IBOutlet UITextField *currencyTextField;
@property (strong, nonatomic) IBOutlet UITextField *categoryTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)onCancelButton:(id)sender;
-(IBAction)mainViewTapped:(id)sender;

- (IBAction)onSubmitReceipt:(id)sender;
- (IBAction)onPhotoTap:(id)sender;

@property(nonatomic,strong) UIImagePickerController *imagePicker;
@property (assign) UIImagePickerControllerSourceType sourceType;
@property(strong,nonatomic) UIImage * receiptImage;
@property (strong, nonatomic) NSMutableArray *receiptSectionImages;
@property (strong, nonatomic) UIView *selectedView;
@end

@implementation AddReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    // Do any additional setup after loading the view.
    
  //  NSLog (@"%@",self.receipt);
    
     managedContext = [self managedObjectContext];
    
    self.receiptSectionImages = [[NSMutableArray alloc] init];
    
    [self.currencyTextField setDelegate:self];
    [self.categoryTextField setDelegate:self];
    [self.priceTextField setDelegate:self];
    [self.descriptionTextView setDelegate:self];
    
    self.priceLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:16];
    self.currencyLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:16];
    self.categoryLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:16];
    self.descriptionLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:16];
    self.dateOfSaleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:16];
    
    
    self.dateTextField.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15];
    self.priceTextField.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15];
    self.currencyTextField.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15];
    self.categoryTextField.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15];
    self.descriptionTextView.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15];
    
    self.takePhotoButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:17];
    
    [self.descriptionTextView setText:@"Type here                                 100"];
    [self.descriptionTextView setTextColor:[UIColor lightGrayColor]];
    self.descriptionTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.cancelButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(doneButton:)];
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexibleSpace,doneButton, nil]];
    self.priceTextField.inputAccessoryView = keyboardDoneButtonView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, 200)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.backgroundColor = [UIColor whiteColor];
    self.dateTextField.inputView = datePicker;
    
    
    UIToolbar* pickerDoneButtonView = [[UIToolbar alloc] init];
    [pickerDoneButtonView sizeToFit];
    
    UIBarButtonItem *flexibleSpacePicker = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* pickerDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(pickerDoneButton:)];
    
    
    [pickerDoneButtonView setItems:[NSArray arrayWithObjects:flexibleSpacePicker,pickerDoneButton, nil]];
    self.dateTextField.inputAccessoryView = pickerDoneButtonView;
    
    
    if ([self.mode isEqualToString:@"EDIT"])
    {
       // [self.bottomHalfView setUserInteractionEnabled:YES];
         if ([self.subMode isEqualToString:@"UPLOADED_RECEIPT"]){
             
             if ([Internet isInternetAvailable])
             {
                 [Internet addActivityIndicator];
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     
                     NSURL * url = [NSURL URLWithString:[self.receipt valueForKey:@"receipt"]];
                     NSData *imgData = [NSData dataWithContentsOfURL:url];
                     self.receiptImage = [UIImage imageWithData:imgData];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.photoImageView setImage:self.receiptImage];
                         [Internet removeActivityIndicator];
                     });
                     
                     
                 });
             }
             else
             {
                 [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
             }
         }
         else{ // saved receipt
             
             [Internet addActivityIndicator];
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 
                 NSString *imgName = [self.currrentReceipt valueForKey:@"receipt"];
                 
                 UIImage *image = [self readImageFromDocumentsDirectory:imgName];
                 
                 self.receiptImage = image;
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [self.photoImageView setImage:self.receiptImage];
                      [Internet removeActivityIndicator];
                    
                 });
                 
             });
             
         }
        
        
        
        NSString *foreignCurrencyUsed = [self.receipt valueForKey:@"foreign_currency"];
        if (!foreignCurrencyUsed || [foreignCurrencyUsed isEqualToString:@""])
        {
            self.priceTextField.text = [self.receipt valueForKey:@"usd"];
            self.currencyTextField.text = @"USD";
            selectedCurrency = @"USD";
        }
        else
        {
            self.priceTextField.text = [self.receipt valueForKey:@"foreign_currency_amount"];
            self.currencyTextField.text = [self.receipt valueForKey:@"foreign_currency"];
            selectedCurrency = [self.receipt valueForKey:@"foreign_currency"];
        }
        
        self.categoryTextField.text = [self.receipt valueForKey:@"type"];
        self.descriptionTextView.text = [self.receipt valueForKey:@"description"];
        
        
        
        NSDate *d = [self dateFromString:[self.receipt valueForKey:@"receipt_date"] inputFormat:@"yyyy-MM-dd hh:mm a"];
        selectedDate = d;
        self.dateTextField.text = [self stringFromDate:d outputFormat:@"MMM dd, yyyy"];
    }
    else
    {
        [self onTakePhoto:nil];
        //[self.bottomHalfView setUserInteractionEnabled:NO];
        selectedCurrency = @"USD";
        
        selectedDate = [NSDate date];
        self.dateTextField.text = [self stringFromDate:selectedDate outputFormat:@"MMM dd, yyyy"];
    }
    
    receiptImageUpdated = NO;
    
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    
}



-(void)keyboardWillShow:(NSNotification*)notif
{
    CGRect keyboardRect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect windowRect = [self.view.window convertRect:keyboardRect fromWindow:nil];
    CGRect keyboardViewRect = [self.view  convertRect:windowRect fromView:nil];
    
    diff = (self.bottomHalfView.frame.origin.y + self.selectedView.frame.origin.y + self.selectedView.frame.size.height) - keyboardViewRect.origin.y;
    
    
    if (diff > 0) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.view.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y - diff - 20,self.view.frame.size.width,self.view.frame.size.height);

        }];
    }
}

-(void)keyboardWillHide:(NSNotification*)notif
{
    
    if (diff > 0) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.view.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y + diff + 20,self.view.frame.size.width,self.view.frame.size.height);
        } completion:^(BOOL finished) {
           
            if(finished){
               
                diff = 0;
            }
            
        }];
    }
    
//    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] lastObject];
//    
//    for (UIButton * btn in tempWindow.subviews) {
//        if (btn.tag == 1007)
//        {
//            [btn removeFromSuperview];
//        }
//    }
    
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.currencyTextField] || [textField isEqual:self.categoryTextField] || [textField isEqual:self.dateTextField])
    {
       
        if ([textField isEqual:self.currencyTextField])
        {
             [self.view endEditing:YES];
            ChooseCurrencyViewController *cc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseCurrency"];
            cc.currencyDelegate = self;
            [self addChildViewController:cc];
            cc.view.frame = self.view.frame;
            cc.view.alpha = 0.0;
            [self.view addSubview:cc.view];
            [cc didMoveToParentViewController:self];
            [UIView animateWithDuration:0.5 animations:^{
                cc.view.alpha = 1.0;
            }];
            return NO;
        }
        else if([textField isEqual:self.categoryTextField])
        {
             [self.view endEditing:YES];
            ChooseCategoryViewController *cc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseCategory"];
            cc.categoryDelegate = self;
            [self addChildViewController:cc];
            cc.view.frame = self.view.frame;
             cc.view.alpha = 0.0;
            [self.view addSubview:cc.view];
            [cc didMoveToParentViewController:self];
            [UIView animateWithDuration:0.5 animations:^{
                cc.view.alpha = 1.0;
            }];
            
            return NO;
        }
        else{
            
            if([self.selectedView isEqual:self.descriptionTextView])
            {
                [self keyboardWillHide:nil];
            }
             self.selectedView = textField;
            return YES;
        }
        
    }
    else
    {
        if([self.selectedView isEqual:self.descriptionTextView])
        {
            [self keyboardWillHide:nil];
        }
        self.selectedView = textField;
        return YES;
    }
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *checkString = @"0123456789.";
    
    if (![checkString containsString:string])
    {
        return YES;
    }
    
    if (textField.text.length < 7)
    {
        if ([textField.text containsString:@"."])
        {
            NSArray *comps = [textField.text componentsSeparatedByString:@"."];
            if (((NSString*)[comps objectAtIndex:1]).length < 2)
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
        return YES;
    }
    
    return NO;
}

-(void)doneButton:(id)sender
{
    [self.priceTextField resignFirstResponder];
}
-(void) pickerDoneButton:(id)sender
{
    UIDatePicker * p = (UIDatePicker*)self.dateTextField.inputView;
    self.dateTextField.text = [self stringFromDate:p.date outputFormat:@"MMM dd, yyyy"];
    selectedDate = p.date;
    [self.dateTextField resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.selectedView = textView;
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Type here                                 100"])
    {
       [textView setTextColor:[UIColor colorWithRed:76/256.0 green:89/256.0 blue:92/256.0 alpha:1.0]];
        [self.descriptionTextView setText:@""];
    }
    
    
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0)
    {
        [textView setTextColor:[UIColor lightGrayColor]];
        [self.descriptionTextView setText:@"Type here                                 100"];
    }
    else
    {
        [textView setTextColor:[UIColor blackColor]];
    }
    
    //[self keyboardWillHide:nil];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


-(void)setCurrency:(NSString *)currency
{
    selectedCurrency = currency;
    self.currencyTextField.text = currency;
}
-(void)setCategory:(NSString *)category
{
    self.categoryTextField.text = category;
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

- (IBAction)onTakePhoto:(id)sender {
    
    [self.view endEditing:YES];
     self.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self showImagePickerController];
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Take Receipt Image" delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library",nil];
//    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
//    [actionSheet showInView:self.view];
}

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    switch (buttonIndex)
//    {
//        case 0:
//            self.sourceType = UIImagePickerControllerSourceTypeCamera;
//            [self showImagePickerController];
//            break;
//        case 1:
//            self.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//            [self performSelector:@selector(showImagePickerController ) withObject:nil afterDelay:1.0];
//            break;
//        default:
//            break;
//    }
//}
-(void) showImagePickerController
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    [self.imagePicker setSourceType:self.sourceType];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = NO;
    self.imagePicker.showsCameraControls = NO;
    self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    
    
    
    CGSize screenBounds = [UIScreen mainScreen].bounds.size;
    
    CGFloat cameraAspectRatio = 4.0f/3.0f;
    
    CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
    CGFloat scale = screenBounds.height / camViewHeight;
    
    self.imagePicker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
    self.imagePicker.cameraViewTransform = CGAffineTransformScale(self.imagePicker.cameraViewTransform, scale, scale);
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults valueForKey:@"SHOW_HELP"] || [[defaults valueForKey:@"SHOW_HELP"] boolValue])
    {
        
        ho = [self.storyboard instantiateViewControllerWithIdentifier:@"Help"];
        
        ho.helpOverlayDelegate = self;
        ho.view.frame = [[UIScreen mainScreen] bounds];
        
        
        self.imagePicker.cameraOverlayView = ho.view;
        
        [self presentViewController:self.imagePicker animated:YES completion:^{
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            
        }];
    }
    else
    {
        
        fo = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstOverlay"];
        
        fo.firstOverlayDelegate = self;
        fo.view.frame = [[UIScreen mainScreen] bounds];
        [fo.previousReceiptView setHidden:YES];
        
        self.imagePicker.cameraOverlayView = fo.view;
        [self presentViewController:self.imagePicker animated:YES completion:^{
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            
        }];
    }
    
   
   
//    
//    [self presentViewController:self.imagePicker animated:YES completion:^{
//    
//       
//    
//    }];
}
-(void)onGotIt
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if (fo)// First overlay is already instatiated, just show it as it is.
    {
        
        self.imagePicker.cameraOverlayView = fo.view;
    }
    else //Instantiate new one.
    {
        fo = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstOverlay"];
        
        fo.firstOverlayDelegate = self;
        fo.view.frame = [[UIScreen mainScreen] bounds];
        [fo.previousReceiptView setHidden:YES];
        
        self.imagePicker.cameraOverlayView = fo.view;
    }
}

-(void) takePicutre
{
    [self.imagePicker takePicture];
}
-(void)onCancel
{
        [self dismissViewControllerAnimated:NO completion:^{
            [self.receiptSectionImages removeAllObjects];
        }];
    
     if ([self.mode isEqualToString:@"ADD"]) {
         
         self.view.alpha = 0.0;
         [self willMoveToParentViewController:nil];
         [self.view removeFromSuperview];
         [self removeFromParentViewController];
     }
    
    
//        [UIView animateWithDuration:0.5 animations:^{
//            self.view.alpha = 0.0;
//        } completion:^(BOOL finished) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self willMoveToParentViewController:nil];
//                [self.view removeFromSuperview];
//                [self removeFromParentViewController];
//            });
//        }];
   

}
-(void)onHelp
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    ho = [self.storyboard instantiateViewControllerWithIdentifier:@"Help"];
    ho.helpOverlayDelegate = self;
    ho.view.frame = [[UIScreen mainScreen] bounds];
    [ho showCheckButton:NO];
    self.imagePicker.cameraOverlayView = ho.view;
}

-(void) onRetake
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.receiptSectionImages removeLastObject];
    self.imagePicker.cameraOverlayView = fo.view;
    
}
-(void)onAddSection
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.imagePicker.cameraOverlayView = fo.view;
    [fo.previousReceiptView setHidden:NO];
    [fo showPreviousReceiptView:(UIImage*)[self.receiptSectionImages lastObject] sectionNumber:self.receiptSectionImages.count+1];
    
    
}
-(void)onDone
{
    //Combine All the images and remove them from array
     self.receiptImage = [self normalizedImage:[self combineImages]] ;
    [self.photoImageView setImage:self.receiptImage];
    [self.takePhotoButton setTitle:@"RETAKE" forState:UIControlStateNormal];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:NO completion:^{
       
        receiptImageUpdated = YES;
        [self.receiptSectionImages removeAllObjects];
          //[self.bottomHalfView setUserInteractionEnabled:YES];
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        
    //    UIImage *imgFinal = [self normalizedImage:img];
    
    
    UIImage *croppedImage = [self croppedImage:img];
    [self.receiptSectionImages addObject:croppedImage];
    
    so = [self.storyboard instantiateViewControllerWithIdentifier:@"SecondOverlay"];
    so.secondOverlayDelegate = self;
    so.view.frame = [[UIScreen mainScreen] bounds];
    so.imageView.image = croppedImage;
    self.imagePicker.cameraOverlayView = so.view;
    
    //NSLog(@" %f %f",img.size.width, img.size.height);
    
}

- (UIImage *)normalizedImage: (UIImage*) originalImage
{
    UIImage *normalizedImage;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(originalImage.size.width/2, originalImage.size.height/2), NO, originalImage.scale/2);
    [originalImage drawInRect:(CGRect){0, 0, CGSizeMake(originalImage.size.width/2, originalImage.size.height/2)}];
    normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return normalizedImage;
}

-(UIImage*)croppedImage:(UIImage*)image
{
    UIImage *imageToCrop = [self fixrotation:image];
    
    double x_radius = ((([[UIScreen mainScreen] bounds].size.width - 40)/ [[UIScreen mainScreen] bounds].size.width)* imageToCrop.size.width)/2;
    double imageCenterX = imageToCrop.size.width/2;
    double Y;
    double height;
    CGRect rect;
    if([self.receiptSectionImages count] > 0)
    {
        height = ((([[UIScreen mainScreen] bounds].size.height - 150)/ [[UIScreen mainScreen] bounds].size.height)* imageToCrop.size.height);
        Y = 100 / [[UIScreen mainScreen] bounds].size.height * imageToCrop.size.height;
    }
    else
    {
      height = ((([[UIScreen mainScreen] bounds].size.height - 50)/ [[UIScreen mainScreen] bounds].size.height)* imageToCrop.size.height);
        Y = 0.0;
        
    }
    
    rect = CGRectMake(imageCenterX - x_radius, Y, x_radius * 2, height);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(imageToCrop.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:4 orientation:imageToCrop.imageOrientation];
    CGImageRelease(imageRef);
    
    return result;
}

- (UIImage *)fixrotation:(UIImage *)image{
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

- (UIImage *)combineImages
{
    UIImage *combinedImage;
    double contextHeight = 0.0;
    double contextWidth = ((UIImage*)[self.receiptSectionImages objectAtIndex:0]).size.width;
    double scale = ((UIImage*)[self.receiptSectionImages objectAtIndex:0]).scale;
    double YOffset = 0.0;
    
    for (UIImage * img in self.receiptSectionImages)
    {
        contextHeight += img.size.height;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(contextWidth , contextHeight), NO,scale);
    for (UIImage * img in self.receiptSectionImages)
    {
         [img drawInRect:(CGRect){0, YOffset, CGSizeMake(img.size.width, img.size.height)}];
         YOffset+= img.size.height;
    }
    
   
    combinedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return combinedImage;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
     [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (IBAction)onCancelButton:(id)sender {
    if ([self.mode isEqualToString:@"ADD"]) {
        
        self.view.alpha = 0.0;
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
         [self.homeViewController viewWillAppear:NO];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(IBAction)mainViewTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)onSubmitReceipt:(id)sender {
    

        if (!self.receiptImage)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please capture the receipt photo." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
        if (!self.priceTextField.text || [self.priceTextField.text isEqualToString:@""])
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter price." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
        if (!self.currencyTextField.text || [self.currencyTextField.text isEqualToString:@""]) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter currency." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
        if (!self.categoryTextField.text || [self.categoryTextField.text isEqualToString:@""]) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a receipt category." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
        if ([self.descriptionTextView.text isEqualToString:@"Type here                                 100"] || [self.descriptionTextView.text isEqualToString:@""])
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a description for the purchase." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         NSString *tripId = [[defaults valueForKey:@"SELECTED_TRIP"] valueForKey:@"id"];
        NSString *userName = [defaults valueForKey:@"USER_NAME"];
        
        NSString *priceUSD;
        if ([selectedCurrency isEqualToString:@"USD"])
        {
            priceUSD = self.priceTextField.text;
        }
        else
        {
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENCIES"];
            NSArray<NSString *> *keys = dict.allKeys;
            for (NSString *key in keys) {
                NSDictionary *currencyDict = dict[key];
                NSString *code = currencyDict[@"code"];
                if ([selectedCurrency isEqualToString:code]) {
                    NSNumber *price = [currencyDict valueForKey:@"rate"];
                    double pUSD = [self.priceTextField.text doubleValue]/[price doubleValue];
                    priceUSD = [NSString stringWithFormat:@"%.2f",pUSD];
                    break;
                }
            }
        }
       
    
   // NSDate *date = [self dateFromString:self.dateTextField.text inputFormat:@"MMM dd, yyyy"];
    NSString * dateString = [self stringFromDate:selectedDate outputFormat:@"yyyy-MM-dd hh:mm a"];
    
    
    
        if ([self.mode isEqualToString:@"EDIT"])
        {
            
            
            
            if ([self.subMode isEqualToString:@"UPLOADED_RECEIPT"]){
                
                if ([Internet isInternetAvailable])
                {
                   
                    
                    [[WebCalls sharedWebCalls] addUpdateReceipt:tripId receiptId:[self.receipt valueForKey:@"id"] priceOtherCurrency:[selectedCurrency isEqualToString:@"USD"]?@"":self.priceTextField.text priceUSD:priceUSD currency:[selectedCurrency isEqualToString:@"USD"]?@"":selectedCurrency type:self.categoryTextField.text description:self.descriptionTextView.text userName:userName image:receiptImageUpdated?self.receiptImage:nil date:dateString caller:self];
                        NSLog (@"%@",dateString);
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
            }
            else // Saved Receipt. Update local database.
            {
                [self.currrentReceipt setValue:tripId forKey:@"trip_id"];
                [self.currrentReceipt setValue: [selectedCurrency isEqualToString:@"USD"]?@"":self.priceTextField.text forKey:@"foreign_currency_amount"];
                [self.currrentReceipt setValue:priceUSD forKey:@"usd"];
                
                [self.currrentReceipt setValue: [selectedCurrency isEqualToString:@"USD"] ? @"": selectedCurrency forKey:@"foreign_currency"];
                [self.currrentReceipt setValue: self.categoryTextField.text forKey:@"type"];
                [self.currrentReceipt setValue: self.descriptionTextView.text forKey:@"receipt_description"];
                [self.currrentReceipt setValue: userName forKey:@"user_name"];
                [self.currrentReceipt setValue: dateString forKey:@"date"];
                
                if(receiptImageUpdated){
                   [self.currrentReceipt setValue: TimeStamp forKey:@"receipt"];
                    NSString * imageName = [self.currrentReceipt valueForKey:@"receipt"];
                    [self writeImageToDocumentsDirectory:imageName forImage:self.receiptImage];
                }
                
                NSError *error = nil;
                if (![managedContext save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
                else{ //saved. So the image to documents directory
                    
                    [[[UIAlertView alloc] initWithTitle:nil message:@"This receipt has been updated successfully and is available for uploading in \"Saved For Later\" list." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
                
                 [self.navigationController popViewControllerAnimated:YES];
            }
            
            
        }
        else
        {
            [[WebCalls sharedWebCalls] addUpdateReceipt:tripId receiptId:nil priceOtherCurrency:[selectedCurrency isEqualToString:@"USD"]?@"":self.priceTextField.text priceUSD:priceUSD currency:[selectedCurrency isEqualToString:@"USD"]?@"":selectedCurrency type:self.categoryTextField.text description:self.descriptionTextView.text userName:userName image:self.receiptImage date:dateString caller:self];
            NSLog (@"%@",dateString);//
            //Create core data object for receipt in case it fails to upload.
            
            self.currrentReceipt = [NSEntityDescription insertNewObjectForEntityForName:@"Receipts" inManagedObjectContext:managedContext];
            
            [self.currrentReceipt setValue:tripId forKey:@"trip_id"];
            [self.currrentReceipt setValue: [selectedCurrency isEqualToString:@"USD"]?@"":self.priceTextField.text forKey:@"foreign_currency_amount"];
            [self.currrentReceipt setValue:priceUSD forKey:@"usd"];
            
            [self.currrentReceipt setValue: [selectedCurrency isEqualToString:@"USD"] ? @"": selectedCurrency forKey:@"foreign_currency"];
            [self.currrentReceipt setValue: self.categoryTextField.text forKey:@"type"];
            [self.currrentReceipt setValue: self.descriptionTextView.text forKey:@"receipt_description"];
            [self.currrentReceipt setValue: userName forKey:@"user_name"];
            [self.currrentReceipt setValue: TimeStamp forKey:@"receipt"];
            [self.currrentReceipt setValue: dateString forKey:@"date"];
        }
    }

- (IBAction)onPhotoTap:(id)sender {
    
    if (self.photoImageView.image)
    {
        ReceiptImageViewController *cc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReceiptImage"];
        cc.img = self.photoImageView.image;
        [self addChildViewController:cc];
        cc.view.frame = self.view.frame;
        cc.view.alpha = 0.0;
        [self.view addSubview:cc.view];
        [cc didMoveToParentViewController:self];
        [UIView animateWithDuration:0.5 animations:^{
            cc.view.alpha = 1.0;
        }];
    }
}

-(void)didGetWebResponse:(id)response forWebCall:(NSString *)webCall
{
    if (response)
    {
        if ([webCall isEqualToString:@"add_receipt"] || [webCall isEqualToString:@"update_receipt"])
        {
            NSString *status = [response valueForKey:@"status"];
            NSString *message = [[response valueForKey:@"messages"] objectAtIndex:0];
            if ([status isEqualToString:@"success"])
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"This receipt has been successfully uploaded." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];

                if ([self.mode isEqualToString:@"ADD"]) {
                    
                    [managedContext deleteObject:self.currrentReceipt];
                    
                    self.view.alpha = 0.0;
                    [self willMoveToParentViewController:nil];
                    [self.view removeFromSuperview];
                    [self removeFromParentViewController];
                    [self.homeViewController viewWillAppear:NO];
                }
                else
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                [[NSNotificationCenter defaultCenter] removeObserver:self];
            }
            else if ([message isEqualToString:@"Invalid trip ID or trip has been archived."])
            {
                if ([self.mode isEqualToString:@"ADD"]) {
                    
                    [managedContext deleteObject:self.currrentReceipt];
                    
                    self.view.alpha = 0.0;
                    [self willMoveToParentViewController:nil];
                    [self.view removeFromSuperview];
                    [self removeFromParentViewController];
                    
                    [self.homeViewController viewWillAppear:NO];
                    
                }
                else
                {
                    [self.navigationController popToViewController:self.homeViewController animated:NO];
                }
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                
                
            }
            
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Oops Something Went Wrong!" message:@"Please try again shortly." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                
                
                
            }
        }
        
    }
}

-(void)networkIssueHandler
{
    if ([self.mode isEqualToString:@"ADD"]) {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"We are having trouble uploading this receipt right now.\n\nWould you like to save this receipt for when you find a better internet connection?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Go Back", @"Save for Later",nil] ;
        
       
        
        [alert show];
    }
    else
    {
        if ([self.subMode isEqualToString:@"UPLOADED_RECEIPT"]){
            
              [[[UIAlertView alloc] initWithTitle:nil message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
        }
        else // Saved Receipt. Update local database.
        {
            
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1){
        
        NSError *error = nil;
        if (![managedContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else{ //saved. So the image to documents directory
            
            NSString * imageName = [self.currrentReceipt valueForKey:@"receipt"];
            [self writeImageToDocumentsDirectory:imageName forImage:self.receiptImage];
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if(![defaults valueForKey:@"SHOW_HELP_SAVED"] || [[defaults valueForKey:@"SHOW_HELP_SAVED"] boolValue])
        {
            
            SavedReceiptHelpViewController *sh = [self.storyboard instantiateViewControllerWithIdentifier:@"SavedHelp"];
            sh.savedHelpOverlayDelegate = self;
            
            [self presentViewController:sh animated:YES completion:^{
                
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
                
            }];
            
        }
        else{
            
            self.view.alpha = 0.0;
            [self willMoveToParentViewController:nil];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [self.homeViewController viewWillAppear:NO];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
        }
        
    }
    
}

-(void) onGotSavedHelpButton
{
    [self dismissViewControllerAnimated:NO completion:^{
        
        self.view.alpha = 0.0;
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        [self.homeViewController viewWillAppear:NO];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
-(void) writeImageToDocumentsDirectory:(NSString *)imageName forImage :(UIImage*) image {
    
    NSData * pngData = UIImagePNGRepresentation(image);
    
    
    
    NSString *filePath = [[self getDocumentsDirectorypath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    [pngData writeToFile:filePath atomically:YES];
}

-(UIImage*) readImageFromDocumentsDirectory :(NSString*) imageName {
    
    NSString *filePath = [[self getDocumentsDirectorypath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
    
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:pngData];
    
    return image;
}

-(NSString*) getDocumentsDirectorypath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    return documentsPath;
}

-(NSString*)stringFromDate:(NSDate*)date outputFormat:(NSString*)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = format;
    return [formatter stringFromDate:date];
}
    



-(NSDate*) dateFromString:(NSString*)string inputFormat:(NSString*)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = format;
    return [formatter dateFromString:string];
}

@end
