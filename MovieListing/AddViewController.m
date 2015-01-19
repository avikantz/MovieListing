//
//  AddViewController.m
//  MovieListing
//
//  Created by Avikant Saini on 1/12/15.
//  Copyright (c) 2015 avikantz. All rights reserved.
//

#import "AddViewController.h"

@interface AddViewController ()

@end

@implementation AddViewController {
	NSMutableArray *catList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Set the delegates of the fields to self
	[self.CategoryField setDelegate:self];
	[self.NameField setDelegate:self];
	
	[_DoneButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:18.0f]} forState:UIControlStateNormal];
	
	// Initialize the 'catList' Array by initially adding 'Add New...'
	catList = [[NSMutableArray alloc] initWithObjects:@"Add New...", nil];
	for (NSString *value in [[NSUserDefaults standardUserDefaults] objectForKey:@"CategoryList"])
		[catList addObject:[NSString stringWithFormat:@"%@", value]];
	
	// Setting the delegate and datasource of the pickerview to self
	_CategoryPicker.dataSource = self;
	_CategoryPicker.delegate = self;
	
	_CategoryPicker.layer.transform = CATransform3DMakeTranslation(0, self.view.frame.size.height, 0);
	_PickerToolbar.layer.transform = CATransform3DMakeTranslation(0, self.view.frame.size.height, 0);
	_CategoryField.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5);
	_NameField.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.4);
	[UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		_CategoryPicker.layer.transform = CATransform3DIdentity;
		_PickerToolbar.layer.transform = CATransform3DIdentity;
		_CategoryField.layer.transform = CATransform3DIdentity;
		_NameField.layer.transform = CATransform3DIdentity;
	}completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[_CategoryField resignFirstResponder];
	[_NameField resignFirstResponder];
}

#pragma mark - TextField Delegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	if (textField == _CategoryField) {
		[_CategoryField resignFirstResponder];
		[_NameField becomeFirstResponder];
	}
	else if (textField == _NameField){
		[_NameField resignFirstResponder];
		if (![[_CategoryField text] isEqualToString:@""] && ![[_NameField text] isEqualToString:@""]) {
			// if the fields are not empty, call the delegate method with the data.
			[self.delegate addItemViewController:self didFinishEntereingMovieWithCategory:[_CategoryField text] andTitled:[_NameField text]];
			
			// pop to the base view controller
			[self.navigationController popToRootViewControllerAnimated:YES];
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Add" message:@"Unable to add a movie without a category (section) title and/or a Name. Please fucking don't leave the fields blank." delegate:self cancelButtonTitle:@"Fine." otherButtonTitles:nil, nil];
			[alert show];
		}
	}
	return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField == _NameField) {
		[UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			_CategoryPicker.layer.transform = CATransform3DMakeTranslation(0, self.view.frame.size.height, 0);
			_PickerToolbar.layer.transform = CATransform3DMakeTranslation(0, self.view.frame.size.height, 0);
		}completion:nil];

	}
	else {
		[UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			_CategoryPicker.layer.transform = CATransform3DIdentity;
			_PickerToolbar.layer.transform = CATransform3DIdentity;
		}completion:nil];
	}
}

#pragma mark - PickerView delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [catList count];
}

//-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
//	NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[catList objectAtIndex:row] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:15.0f]}];
//	return attString;
//}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _CategoryPicker.frame.size.width, 40)];
	[lbl setText: [catList objectAtIndex:row]];
	[lbl setFont: [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:20.0f]];
	[lbl setTextAlignment:NSTextAlignmentCenter];
	[lbl setAlpha: 0.8];
	[lbl setTextColor: [UIColor whiteColor]];
	[lbl setBackgroundColor:[UIColor clearColor]];
	return lbl;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if (row == 0)	// Category is 'Add New...'
		[_CategoryField setText:@""];
	else
		[_CategoryField setText:[catList objectAtIndex:row]];
}

#pragma mark - Done Action

- (IBAction)DoneAction:(id)sender {
	[UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		_CategoryPicker.layer.transform = CATransform3DIdentity;
		_PickerToolbar.layer.transform = CATransform3DIdentity;
	}completion:nil];
	if ([[_CategoryField text] isEqualToString:@""]) {
		[_CategoryField becomeFirstResponder];
	}
	else {
		[_CategoryField resignFirstResponder];
		[_NameField becomeFirstResponder];
	}
}

@end
