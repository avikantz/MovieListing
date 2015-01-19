//
//  TableViewController.m
//  MovieListing
//
//  Created by Avikant Saini on 9/17/14.
//  Copyright (c) 2014 avikantz. All rights reserved.
//

#import "TableViewController.h"
#import "TableCell.h"
#import "topView.h"
#define UIColorFromRGBWithAlpha(rgbValue, a) [UIColor \
		colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
			   green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
				blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@interface TableViewController ()

@end

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: UIColorFromRGBWithAlpha(0x66ffcc, 1), NSFontAttributeName: [UIFont fontWithName:@"EtelkaNarrowTextPro" size:20.0f]}];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"MOVIES LIST" style:UIBarButtonItemStylePlain target:self action:nil];
	[backButton setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColorFromRGBWithAlpha(0x66ffcc, 1), NSFontAttributeName: [UIFont fontWithName:@"EtelkaNarrowTextPro" size:20.0f]} forState:UIControlStateNormal];
	[self.sortButton setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColorFromRGBWithAlpha(0x66ffcc, 1), NSFontAttributeName: [UIFont fontWithName:@"EtelkaNarrowTextPro" size:20.0f]} forState:UIControlStateNormal];
	[self.navigationItem setBackBarButtonItem:backButton];
	
	self.tableView.contentOffset = CGPointMake(0.0, 44.0);
	
	// Buttons in Navigation Controller
	self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: _addButton, _searchButton, nil];
	self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: _refreshButton, _sortButton, nil];
	self.navigationController.toolbarHidden = YES;
	
	// Load data from the defaults (saved, sorted data stuff) if available
	if ([self dataAvailableFromDefaults])
		_Movies = [NSJSONSerialization JSONObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"MoviesData"] options:kNilOptions error:nil];
	// Else load the data from the included json file
	else
		_Movies = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"MoviesArray" ofType:@"json"]] options:kNilOptions error: nil];
	
	// Section Titles Array
	_MovieListing = [[NSMutableArray alloc] initWithArray:[[_Movies allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	
	[self populateFullList];
	[self writeDataToDefaults];
	[self.tableView reloadSectionIndexTitles];
	
	// We want to display only a few section headers hence an array for all the headers we want to display
	_IndexTitles = @[@"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
	
	_SearchResults = [[NSMutableArray alloc] init];
	
	// Changing the appearence of SearchBar
	self.searchDisplayController.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
	self.searchDisplayController.searchBar.tintColor = UIColorFromRGBWithAlpha(0x66ff66, 1);
	[[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{ NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:15.0f], NSForegroundColorAttributeName: UIColorFromRGBWithAlpha(0xffffff, 0.7)}];
	[self.searchDisplayController.searchBar setScopeBarButtonTitleTextAttributes:@{ NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:15.0f], NSForegroundColorAttributeName: UIColorFromRGBWithAlpha(0xffffff, 0.7)} forState:UIControlStateNormal];
	
	// Geerating a blank Black image for scope bar
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.view.frame.size.width, 44), NO, 0);
	UIBezierPath *imagePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.view.frame.size.width, 44)];
	[[UIColor blackColor] setFill];
	[imagePath fill];
	UIImage *blackImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[self.searchDisplayController.searchBar setScopeBarBackgroundImage:blackImage];
	
	self.tableView.alpha = 0;
	self.tableView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(1.0, 0.5, 0.5), 0, self.view.frame.size.height, 0);
	[UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		self.tableView.alpha = 1;
		self.tableView.layer.transform = CATransform3DIdentity;
	}completion:nil];
	[self addHiddenTitleForTableView];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) writeDataToDefaults {
	NSData *data = [NSJSONSerialization dataWithJSONObject:_Movies options:kNilOptions error:nil];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"MoviesData"];
	[[NSUserDefaults standardUserDefaults] setObject:_MovieListing forKey:@"CategoryList"];
}

-(BOOL) dataAvailableFromDefaults {
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"MoviesData"];
	if (data == nil)
		return NO;
	return YES;
}

-(void) populateFullList {
	// List of all the movies without the sections for searching purposes - Loop through each array in list (key) then loop through that array, adding each object to the 'FullList' array
	_FullList = [[NSMutableArray alloc] init];
	for (NSString *key in _Movies) {
		for (NSString *key2 in _Movies[key])
			[_FullList addObject:[NSString stringWithFormat:@"%@", key2]];
	}
	_FullList = [NSMutableArray arrayWithArray:[_FullList sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
}

-(void) addHiddenTitleForTableView {
	topView *topV = [[[NSBundle mainBundle] loadNibNamed:@"topView" owner:self options:nil] objectAtIndex:0];
	[topV setFrame:CGRectMake(0, -(self.view.frame.size.height), self.view.frame.size.width, self.view.frame.size.height)];
	topV.MovieLabel.text = [NSString stringWithFormat:@"%li", (long)[_FullList count]];
	topV.MovieLabel.font = [UIFont fontWithName:@"Tall Films Expanded" size:50.0f];
	topV.avikantzLabel.text = @"@avikantz";
	topV.avikantzLabel.font = [UIFont fontWithName:@"DJB A Bit of Flaire" size:25.0f];
	[self.tableView addSubview:topV];
}

#pragma mark - Search display control and search results

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
	
	// Filter using Perdicate
    _SearchResults = [[NSMutableArray alloc]initWithArray:[_FullList filteredArrayUsingPredicate:resultPredicate]];
	
	if ([scope isEqualToString:@"Oldest First"]) {
		_SearchResults = [NSMutableArray arrayWithArray:[_SearchResults sortedArrayUsingComparator:^(NSString *a, NSString *b){
			NSString *aa = [a substringWithRange:NSMakeRange([a length] - 5, 4)];
			NSString *bb = [b substringWithRange:NSMakeRange([b length] - 5, 4)];
			if ([aa compare:bb] == NSOrderedAscending)
				return NSOrderedAscending;
			return NSOrderedDescending;
		}]];
	}
	else if ([scope isEqualToString:@"Newest First"]) {
		_SearchResults = [NSMutableArray arrayWithArray:[_SearchResults sortedArrayUsingComparator:^(NSString *a, NSString *b){
			NSString *aa = [a substringWithRange:NSMakeRange([a length] - 5, 4)];
			NSString *bb = [b substringWithRange:NSMakeRange([b length] - 5, 4)];
			if ([aa compare:bb] == NSOrderedAscending)
				return NSOrderedDescending;
			return NSOrderedAscending;
		}]];
	}
	else {
		_SearchResults = [NSMutableArray arrayWithArray: [_SearchResults sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
	}
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	[self filterContentForSearchText:[self.searchDisplayController.searchBar text]
							   scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
	return YES;
}



- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	if (tableView == self.searchDisplayController.searchResultsTableView)
		return 1;
	else
		return [_MovieListing count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (tableView == self.searchDisplayController.searchResultsTableView)
        return [_SearchResults count];
	
	else {
        NSString *sectionTitle = [_MovieListing objectAtIndex:section];
		NSArray *sectionx = [_Movies objectForKey:sectionTitle];
		return [sectionx count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Stuff";
	TableCell *cell;
	
	// Initialize the cell if it's blank
	if(cell == nil){
		cell = [[TableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	// Initialize the cell if the search display controller is active
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		// Dequeue the cell with identifer
		cell = (TableCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.MovieList.text = [_SearchResults objectAtIndex:indexPath.row];
		self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor blackColor];
		self.searchDisplayController.searchResultsTableView.backgroundView.backgroundColor = [UIColor blackColor];
		self.searchDisplayController.searchResultsTableView.sectionIndexBackgroundColor = [UIColor blackColor];
		self.searchDisplayController.searchResultsTableView.sectionIndexColor = [UIColor blackColor];
		self.searchDisplayController.searchResultsTableView.separatorColor = [UIColor clearColor];
		self.searchDisplayController.searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
	}
	else {
		cell = (TableCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		cell.MovieList.text = [[_Movies objectForKey:[_MovieListing objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    }
	
	
	
	return cell;
}

// Since we don't want all the index titles, we return the custom index titles made for the tableView
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _IndexTitles;
}

// Just returning the section for the psrticular index title
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return [_MovieListing indexOfObject:title];
}

// Add a special last footer containing the count of the Movies
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
	if (section == _MovieListing.count -1){
		footer.backgroundColor = [UIColor clearColor];
		UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 20)];
		lbl.backgroundColor = [UIColor clearColor];
		lbl.text = [NSString stringWithFormat:@"%li MOVIES", (long)[_FullList count]];
		lbl.alpha = 0.3;
		[lbl setTextAlignment:NSTextAlignmentCenter];
		[lbl setFont: [UIFont fontWithName:@"EtelkaNarrowTextPro" size:18.0]];
		[lbl setTextColor:[UIColor whiteColor]];
		[footer addSubview:lbl];
		self.tableView.tableFooterView=footer;
	}
	return footer;
}

// Overriding the 'titleForHeaderInSection' method by providing a custom view
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	UIView *header = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 30)];
	header.backgroundColor = [UIColor clearColor];
	UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 30)];
	lbl.backgroundColor = [UIColor clearColor];
	lbl.text = [NSString stringWithFormat:@"%@ (%li)",[_MovieListing objectAtIndex:section], (long)[[_Movies objectForKey:[_MovieListing objectAtIndex:section]] count]];
	lbl.alpha = 0.5;
	[lbl setTextAlignment:NSTextAlignmentCenter];
	[lbl setFont: [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:18.0]];
	[lbl setTextColor:[UIColor whiteColor]];
	if (self.searchDisplayController.isActive){
		lbl.text = [NSString stringWithFormat:@"%li Results", (long)[_SearchResults count]];
		header.backgroundColor = [UIColor blackColor];
	}
	[header addSubview:lbl];
	[self tableView:tableView titleForHeaderInSection:section];
	return header;
}

/*
 -(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (self.searchDisplayController.isActive)
 return [NSString stringWithFormat:@"%li Results", (long)[_SearchResults count]];
	return [NSString stringWithFormat:@"%@ (%li)",[_MovieListing objectAtIndex:section], (long)[[_Movies objectForKey:[_MovieListing objectAtIndex:section]] count]];
 }
*/

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == [tableView numberOfSections] - 1) {
		// Special thick footer in section for the last one
		return 60.0;
	}
	else {
		return 15.0;
	}
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[UIView animateWithDuration:5.0 animations:^{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}];
}

#pragma mark - Tableview animation

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	_lastContentOffset = scrollView.contentOffset;
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	// Setting the scrollDirection property
	if (_lastContentOffset.y < (int)scrollView.contentOffset.y)
		_scrollDirection = ScrollDirectionUp;
	else
		_scrollDirection = ScrollDirectionDown;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!(self.searchDisplayController.isActive)) {
		CATransform3D rotation3d;
		if (self.scrollDirection == ScrollDirectionUp)
			rotation3d = CATransform3DMakeRotation(M_PI/12, 0.0, 0.7, 0.4);
		else
			rotation3d = CATransform3DMakeRotation(-M_PI/12, 0.0, 0.7, 0.4);
		rotation3d.m33 = 1.0/-600;
		
		// Define the initial state
		cell.layer.shadowColor = [[UIColor clearColor]CGColor];
		cell.backgroundView.backgroundColor = [UIColor clearColor];
		cell.layer.shadowOffset = CGSizeMake(10, 10);
		cell.alpha = 0;
		
		cell.layer.transform = CATransform3DScale(rotation3d, 0.3, 0.3, 0.3);
		cell.layer.anchorPoint = CGPointMake(0, 0.4);
		
		// animate now...
		[UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			cell.layer.transform = CATransform3DIdentity;
			cell.alpha = 1;
			cell.layer.shadowOffset = CGSizeMake(0, 0);
		} completion:nil];
	}
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
	view.alpha = 0;
	if (self.scrollDirection == ScrollDirectionUp) {
		view.frame = CGRectMake(0, -40, self.view.frame.size.width, 40);
		view.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
	}
	else {
		view.frame = CGRectMake(0, -10, self.view.frame.size.width, 40);
		view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5);
	}
	// Do not animate when the search is active
	[UIView animateWithDuration:(self.searchDisplayController.isActive)?0:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		view.alpha = 1;
		view.layer.transform = CATransform3DIdentity;
		view.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
	} completion:nil];
}

-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
	if (section == _MovieListing.count - 1) {
		view.alpha = 0;
		view.layer.transform = CATransform3DMakeScale(0.2, 0.2, 0.2);
		[UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveLinear animations:^{
			view.alpha = 1;
			view.layer.transform = CATransform3DIdentity;
		}completion:nil];
	}
}

#pragma mark - Deleting rows from the table view

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.searchDisplayController.isActive)
		return NO;	// Let's keep the search display controller for search purposes only for the glory of Satan
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellTitle = [_Movies[_MovieListing[indexPath.section]] objectAtIndex:indexPath.row];
	NSLog(@"\nMovie Deleted : '%@'\t from Section : '%@'", cellTitle, _MovieListing[indexPath.section]);
	NSMutableDictionary *Movies2 = [[NSMutableDictionary alloc] init];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		// Loop through the keys in the dictionary
		for (NSString *key in _Movies) {
			NSMutableArray *Array2 = [[NSMutableArray alloc] init];
			// Loop through values in the gorram array of that key object
			for (NSString *value in _Movies[key]) {
				// if the 'value' is not equal to the thing we want to be deleted, then we add the object to 'Array2'
				if (![value isEqualToString:cellTitle]) {
					[Array2 addObject:value];
				}
			}
			// Setting object 'Array2' to the 'Movies2' dictionary
			[Movies2 setObject:Array2 forKey:key];
		}
		// Set 'Movies' as 'Movies2'
		_Movies = Movies2;
		// Now delete the row at that index path.
		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		
		// If all the rows of a section are deleted then delete the section...
		if ([self tableView:tableView numberOfRowsInSection:indexPath.section] == 0) {
			// Remove the section title from the section titles array.
			NSLog(@"\nRemoved Section : '%@'", _MovieListing[indexPath.section]);
			[_MovieListing removeObjectAtIndex:indexPath.section];
			[self.tableView deleteSections:[[NSIndexSet alloc] initWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationRight];
		}
		// Populate the 'FullList' i.e. the list for search results.
		[self populateFullList];
		// Refresh the hidden title header for table view
		[self addHiddenTitleForTableView];
		
		[self writeDataToDefaults];
    }
}

#pragma mark - Adding data to table view

- (IBAction)AddAction:(id)sender {
	AddViewController *avc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddViewController"];
	avc.delegate = self;
	[[self navigationController] pushViewController:avc animated:YES];
}

// Delegate method of 'AddViewController'
-(void)addItemViewController:(AddViewController *)controller didFinishEntereingMovieWithCategory:(NSString *)category andTitled:(NSString *)title{
	NSLog(@"\nMovie added : '%@'\tin section : '%@'", title, category);
	BOOL isMovieAlreadyPresent = NO;
	for (NSString *movie in _FullList)
		if ([movie isEqualToString:title])
			isMovieAlreadyPresent = YES;
	
	if (isMovieAlreadyPresent) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hey-Oh!" message:[NSString stringWithFormat:@"'%@' is already present in the list! No use of adding it again.", title] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
		[alert show];
	}
	else {
		NSMutableDictionary *Movies2 = [[NSMutableDictionary alloc] init];
		BOOL keyAlreadyPresent = NO;
		for (NSString *key in _Movies) {
			NSMutableArray *Array2 = [[NSMutableArray alloc] init];
			for (NSString *value in _Movies[key]) {
				[Array2 addObject:value];
			}
			if ([key isEqualToString:category]) {
				[Array2 addObject:title];
				keyAlreadyPresent = YES;
			}
			if ([key length] == 1) {
				NSArray *sortedArray2 = [Array2 sortedArrayUsingComparator:^(NSString *a, NSString *b){
				return [a caseInsensitiveCompare:b];
				}];
				[Movies2 setObject:sortedArray2 forKey:key];
			}
			else {
				NSArray *sortedArray2 = [Array2 sortedArrayUsingComparator:^(NSString *a, NSString *b){
					NSString *aa = [a substringWithRange:NSMakeRange([a length] - 5, 4)];
					NSString *bb = [b substringWithRange:NSMakeRange([b length] - 5, 4)];
					if ([aa compare:bb] == NSOrderedAscending)
						return NSOrderedAscending;
					return NSOrderedDescending;
				}];
				[Movies2 setObject:sortedArray2 forKey:key];
			}
		}
		if (!keyAlreadyPresent) {
			[Movies2 setObject:[[NSMutableArray alloc] initWithArray:@[title]] forKey:category];
			[_MovieListing addObject:category];
			_MovieListing = [NSMutableArray arrayWithArray:[_MovieListing sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
		}
		_Movies = Movies2;
		[self populateFullList];
		[self addHiddenTitleForTableView];
		[self writeDataToDefaults];
		[self.tableView reloadData];
	}
}

#pragma mark - Sorting Action

- (IBAction)SortAction:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sort" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Alphabetically", @"Oldest First", @"Newest First", @"Default", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([title isEqualToString:@"Alphabetically"]){
		NSMutableDictionary *Movies2 = [[NSMutableDictionary alloc] init];
		for (NSString *key in _Movies) {
			NSMutableArray *Array2 = [[NSMutableArray alloc] init];
			for (NSString *value in _Movies[key])
				[Array2 addObject:value];
			NSArray *sortedArray2 = [Array2 sortedArrayUsingComparator:^(NSString *a, NSString *b){
				return [a caseInsensitiveCompare:b];
			}];
			[Movies2 setObject:sortedArray2 forKey:key];
		}
		_Movies = Movies2;
		[self populateFullList];
		[self addHiddenTitleForTableView];
		[self writeDataToDefaults];
		[self.tableView reloadData];
	}
	else if ([title isEqualToString:@"Oldest First"]) {
		NSMutableDictionary *Movies2 = [[NSMutableDictionary alloc] init];
		for (NSString *key in _Movies) {
			NSMutableArray *Array2 = [[NSMutableArray alloc] init];
			for (NSString *value in _Movies[key])
				[Array2 addObject:value];
			NSArray *sortedArray2 = [Array2 sortedArrayUsingComparator:^(NSString *a, NSString *b){
				NSString *aa = [a substringWithRange:NSMakeRange([a length] - 5, 4)];
				NSString *bb = [b substringWithRange:NSMakeRange([b length] - 5, 4)];
				if ([aa compare:bb] == NSOrderedAscending)
					return NSOrderedAscending;
				return NSOrderedDescending;
			}];
			[Movies2 setObject:sortedArray2 forKey:key];
		}
		_Movies = Movies2;
		[self populateFullList];
		[self addHiddenTitleForTableView];
		[self writeDataToDefaults];
		[self.tableView reloadData];
	}
	else if ([title isEqualToString:@"Newest First"]) {
		NSMutableDictionary *Movies2 = [[NSMutableDictionary alloc] init];
		for (NSString *key in _Movies) {
			NSMutableArray *Array2 = [[NSMutableArray alloc] init];
			for (NSString *value in _Movies[key])
				[Array2 addObject:value];
			NSArray *sortedArray2 = [Array2 sortedArrayUsingComparator:^(NSString *a, NSString *b){
				NSString *aa = [a substringWithRange:NSMakeRange([a length] - 5, 4)];
				NSString *bb = [b substringWithRange:NSMakeRange([b length] - 5, 4)];
				if ([aa compare:bb] == NSOrderedAscending)
					return NSOrderedDescending;
				return NSOrderedAscending;
			}];
			[Movies2 setObject:sortedArray2 forKey:key];
		}
		_Movies = Movies2;
		[self populateFullList];
		[self addHiddenTitleForTableView];
		[self writeDataToDefaults];
		[self.tableView reloadData];
	}
	else if ([title isEqualToString:@"Default"]) {
		NSMutableDictionary *Movies2 = [[NSMutableDictionary alloc] init];
		for (NSString *key in _Movies) {
			NSMutableArray *Array2 = [[NSMutableArray alloc] init];
			for (NSString *value in _Movies[key])
				[Array2 addObject:value];
			if ([key length] == 1) {
				NSArray *sortedArray2 = [Array2 sortedArrayUsingComparator:^(NSString *a, NSString *b){
					return [a caseInsensitiveCompare:b];
				}];
				[Movies2 setObject:sortedArray2 forKey:key];
			}
			else {
				NSArray *sortedArray2 = [Array2 sortedArrayUsingComparator:^(NSString *a, NSString *b){
					NSString *aa = [a substringWithRange:NSMakeRange([a length] - 5, 4)];
					NSString *bb = [b substringWithRange:NSMakeRange([b length] - 5, 4)];
					if ([aa compare:bb] == NSOrderedAscending)
						return NSOrderedAscending;
					return NSOrderedDescending;
				}];
				[Movies2 setObject:sortedArray2 forKey:key];
			}
		}
		_Movies = Movies2;
		[self populateFullList];
		[self addHiddenTitleForTableView];
		[self writeDataToDefaults];
		[self.tableView reloadData];
	}
	else {
		
	}
}

#pragma mark - Search and Refresh Action

- (IBAction)SearchAction:(id)sender {
	// Set the searchDisplayController active and set the searchBar active
	[self.searchDisplayController setActive:YES animated:YES];
	[self.searchDisplayController.searchBar becomeFirstResponder];
}

- (IBAction)RefreshAction:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset?" message:@"Do you really want to reset data to its original state?" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Yep", nil];
	[alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	if([title isEqualToString:@"Yep"]){
		// Restore the data to original state from the file
		_Movies = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"MoviesArray" ofType:@"json"]] options:kNilOptions error: nil];
		
		// Section Titles Array
		_MovieListing = [[NSMutableArray alloc] initWithArray:[[_Movies allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
		
		[self populateFullList];
		[self addHiddenTitleForTableView];
		[self writeDataToDefaults];
		[self.tableView reloadData];
		
		NSLog(@"Data Resetted!");
	}
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
