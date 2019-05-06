//
//  AddViewController.m
//  FancyFence
//
//  Created by user148018 on 5/1/19.
//

#import "AddViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface AddViewController ()

@property UIView *activeField;

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // Add Done & Cancel buttons to number keyboard
//    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
//    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
//    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)],
//                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
//                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
//
//    numberToolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    [numberToolbar sizeToFit];
//    self.rangeTextField.inputAccessoryView = numberToolbar;
    
}

//-(void)cancelNumberPad{
//    [self.rangeTextField resignFirstResponder];
//    self.rangeTextField.text = @"";
//}
//
//-(void)doneWithNumberPad{
////    NSString *numberFromTheKeyboard = self.rangeTextField.text;
//    [self.rangeTextField resignFirstResponder];
//}

- (IBAction)closeKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    
    AppDelegate *objAppDel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [objAppDel managedObjectContext];
    
    // Create a new managed object
    NSManagedObject *newFence = [NSEntityDescription insertNewObjectForEntityForName:@"Fence" inManagedObjectContext:context];
    
    [newFence setValue:[NSNumber numberWithDouble:self.mapView.centerCoordinate.latitude] forKey:@"latitude"];
    [newFence setValue:[NSNumber numberWithDouble:self.mapView.centerCoordinate.longitude] forKey:@"longitude"];
    [newFence setValue:[NSNumber numberWithInt:[self.rangeTextField.text intValue]] forKey:@"range"];
    [newFence setValue:self.entryTextField.text forKey:@"uponEntry"];
    [newFence setValue:self.exitTextField.text forKey:@"uponExit"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
  
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
