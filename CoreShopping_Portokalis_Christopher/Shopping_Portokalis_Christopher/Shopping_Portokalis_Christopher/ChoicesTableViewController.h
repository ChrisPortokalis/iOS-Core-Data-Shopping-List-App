//
//  ChoicesTableViewController.h
//  Shopping_Portokalis_Christopher
//
//  Created by PORTOKALIS CHRISTOPHER G on 10/2/14.
//  Copyright (c) 2014 PORTOKALIS CHRISTOPHER G. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShoppingItem.h"
#import "ChoicesEntity.h"
#import "AppDelegate.h"

@interface ChoicesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property ChoicesEntity* segChoice;
@property NSString* segChoiceName;
@property UITableView* prevTView;
@property NSFetchedResultsController* shoppingViewFetch;

@end
