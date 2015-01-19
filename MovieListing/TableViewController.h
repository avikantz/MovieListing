//
//  TableViewController.h
//  MovieListing
//
//  Created by Avikant Saini on 9/17/14.
//  Copyright (c) 2014 avikantz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddViewController.h"

@interface TableViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate, UIActionSheetDelegate, AddViewControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *Movies;		// Storing the entire dictionary
@property (nonatomic, strong) NSMutableArray *MovieListing;		// Sorting the dictionary Keys
@property (nonatomic, strong) NSArray *IndexTitles;				// Separate array for index titles (since we don't want to display all)
@property (nonatomic, strong) NSMutableArray *FullList;			// Array to store all the values (non keyed) in a linear way
@property (nonatomic, strong) NSMutableArray *SearchResults;	// Store the search results

- (IBAction)AddAction:(id)sender;
- (IBAction)RefreshAction:(id)sender;
- (IBAction)SortAction:(id)sender;
- (IBAction)SearchAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) NSInteger scrollDirection;
typedef enum ScrollDirection {
	ScrollDirectionNone,
	ScrollDirectionUp,
	ScrollDirectionDown,
} ScrollDirection;


@end
