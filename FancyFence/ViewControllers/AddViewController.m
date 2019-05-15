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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set received data from segue
    self.mapView.region = self.userRegion;
    
    if(self.fence) {
        self.nameTextField.text = self.fence.title;
        self.rangeTextField.text = [NSString stringWithFormat:@"%d", self.fence.radius];
        self.entryTextField.text = self.fence.entry;
        self.exitTextField.text = self.fence.exit;
        self.mapView.centerCoordinate = self.fence.coordinate;
    }
    
    self.mapView.showsUserLocation = YES;
  
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

- (IBAction)closeKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    
    NSNumber *radius = [NSNumber numberWithInt:[self.rangeTextField.text intValue]];
    NSNumber *lat = [NSNumber numberWithDouble:self.mapView.centerCoordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:self.mapView.centerCoordinate.longitude];
    
    if(self.fence) {
        
        [self.delegate editFence:self.fence withName:self.nameTextField.text Radius:radius Lat:lat Lon:lon Entry:self.entryTextField.text Exit:self.exitTextField.text];
        
    } else {
        
        [self.delegate addFenceWithName:self.nameTextField.text Radius:radius Lat:lat Lon:lon Entry:self.entryTextField.text Exit:self.exitTextField.text];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
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
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

- (IBAction)textFieldChanged:(id)sender {
    [self.saveButton setEnabled:(![self.exitTextField.text isEqual: @""] || ![self.entryTextField.text isEqual:@""]) && ![self.nameTextField.text isEqual:@""] && ![self.rangeTextField.text isEqual: @""]];
}

@end
