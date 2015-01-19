//
//  AddViewController.h
//  MovieListing
//
//  Created by Avikant Saini on 1/12/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddViewController;

@protocol AddViewControllerDelegate <NSObject>
// Add delegate methods to pass data
- (void)addItemViewController:(AddViewController *)controller didFinishEntereingMovieWithCategory:(NSString *)category andTitled:(NSString *)title;
@end

@interface AddViewController : UIViewController <UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *CategoryField;
@property (weak, nonatomic) IBOutlet UITextField *NameField;
@property (weak, nonatomic) IBOutlet UIPickerView *CategoryPicker;
@property (weak, nonatomic) IBOutlet UIToolbar *PickerToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *DoneButton;

@property (nonatomic, weak) id <AddViewControllerDelegate> delegate;

- (IBAction)DoneAction:(id)sender;

@end
