//
//  ShoppingListViewController.m
//  Shopping_Portokalis_Christopher
//
//  Created by PORTOKALIS CHRISTOPHER G on 10/2/14.
//  Copyright (c) 2014 PORTOKALIS CHRISTOPHER G. All rights reserved.
//

#import "ShoppingListViewController.h"
#import "ChoicesTableViewController.h"
#import "ShoppingItemEntity.h"
#import "ChoicesEntity.h"

@interface ShoppingListViewController () <NSFetchedResultsControllerDelegate>
@property NSIndexPath* cellIndex;
@property (strong, nonatomic) NSString* inKey;

//core data properties
@property (strong, nonatomic) AppDelegate* appDel;
@property (strong, nonatomic) NSFetchedResultsController *shoppingFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *choicesFetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSIndexPath* rowIndex;


@end

@implementation ShoppingListViewController

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
    self.appDel = [UIApplication sharedApplication].delegate;
    [super viewDidLoad];
    
    
    self.managedObjectContext = self.appDel.managedObjectContext;
    
    [self loadItemData];
    [self loadChoicesData];
    
    if(self.choicesFetchedResultsController.fetchedObjects.count == 0)
    {
        [self setupDB];
        [self loadChoicesData];
    }
    
    //add trash button to navigation bar
    UIBarButtonItem *myTrash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemTrash
                                                                             target: self
                                                                            action: @selector(deleteHandler)];
    
    NSArray* barButtons = [self.navigationItem.rightBarButtonItems arrayByAddingObject: myTrash];
    self.navigationItem.rightBarButtonItems = barButtons;
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    //[self loadChoicesData];
   // [self loadItemData];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //NSLog([NSString stringWithFormat:@"Row Count = %lu", (unsigned long)[self.shoppingFetchedResultsController fetchedObjects].count]);
     return [self.shoppingFetchedResultsController fetchedObjects].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ShoppingItemEntity* item = [self.shoppingFetchedResultsController objectAtIndexPath:indexPath];
    static NSString *CellIdentifier = @"shopListCells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSLog([NSString stringWithFormat:@"Row = %ld Name = %@", (long)indexPath.row, item.itemName]);
    // Configure the cell...
    
    cell.textLabel.text = item.itemName;
    
    if([item.checked  isEqual: @0])
    {
        cell.imageView.image = [UIImage imageNamed: @"ubox.png"];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed: @"cbox.png"];
        
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", item.itemCount];
    
    
    return cell;
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSManagedObject* managed = [self.shoppingFetchedResultsController objectAtIndexPath:indexPath];
    
    ShoppingItemEntity* item = [self.managedObjectContext objectWithID: [managed objectID]];
    
    if([item.checked  isEqual: @1])
    {
        item.checked = @0;
    }
    else
    {
        item.checked = @1;
    }
    
    [self.managedObjectContext save:nil];
    
    [self loadItemData];
    [tableView reloadData];
    
}

//get new item name from choices table unwind segue
-(IBAction) unwindToShop: (UIStoryboardSegue*) segue sender: (UITableViewCell*) sender
{
    bool isInDB = false;
    ChoicesTableViewController *sourceVC = segue.sourceViewController;
    

    NSString* newItemName = sourceVC.segChoiceName;
    ChoicesEntity* newChoice = sourceVC.segChoice;
    

    for(ShoppingItemEntity* choices in self.shoppingFetchedResultsController.fetchedObjects)
    {
        if([choices.itemName isEqualToString:newItemName])
        {
            long count = [choices.itemCount integerValue];
            count++;
            choices.itemCount = [NSNumber numberWithLong:count];
            isInDB = true;
            [self.managedObjectContext save:nil];
            break;
        }
        
    }
    
    
    
    //save object
    if(!isInDB)
    {
        NSEntityDescription *shopEntity = [NSEntityDescription entityForName:@"ShoppingItemEntity" inManagedObjectContext:self.managedObjectContext];
        //choices object to add to DB
        ShoppingItemEntity* item = [[ShoppingItemEntity alloc] initWithEntity: shopEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        item.checked = @0;
        item.itemCount = @1;
        item.itemName = newItemName;
        item.itemsToChoice = newChoice;
        
        
        
        NSError *error = nil;
        
        if (![self.managedObjectContext save:&error])
        {
            if (error)
            {
                NSLog(@"Unable to save record.");
                NSLog(@"%@, %@", error, error.localizedDescription);
            }
            
            // Show Alert View
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your record could not be saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    
    }

    
    [self loadItemData];
    //[self loadChoicesData];
    [self.tableView reloadData];

    
}

//prepare to segue to next view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    ChoicesTableViewController* destVC = segue.destinationViewController;
    
    destVC.prevTView = self.tableView;
    destVC.shoppingViewFetch = self.shoppingFetchedResultsController;
    
  
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.rowIndex = indexPath;
    
    ShoppingItemEntity* item = [self.shoppingFetchedResultsController objectAtIndexPath:indexPath];
    NSManagedObject* managed = [self.shoppingFetchedResultsController objectAtIndexPath:indexPath];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
 
    
        if([item.itemCount integerValue] > 1)
        {
            self.cellIndex = indexPath;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Item Count is More Than One" message:@"Delete One or All?" delegate:self cancelButtonTitle:@"1" otherButtonTitles:@"All",nil];
            [alert show];

        }
        else if([item.itemCount integerValue] == 1)
        {
            ChoicesEntity* choice = item.itemsToChoice;
            choice.choiceToItem = nil;
            [self.managedObjectContext deleteObject: managed];
            [self.managedObjectContext save: nil];
            [self loadItemData];
            [self.tableView reloadData];
        }
        
        
        
    } else {
        NSLog(@"Unhandled editing style! %d", editingStyle);
    }
    

    
  
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
        long countHolder;
   
        if (buttonIndex == 0) {
            
            if([alertView.title isEqualToString: @"Item Count is More Than One"])
            {
                ShoppingItemEntity* item = [self.shoppingFetchedResultsController objectAtIndexPath: self.cellIndex];
                countHolder = [item.itemCount integerValue];
                countHolder--;
                item.itemCount = [NSNumber numberWithLong: countHolder];
                [self.managedObjectContext save: nil];
                [self loadItemData];
                [self.tableView reloadData];
            }
            else
            {
                return;
            }
       
        }
        else if (buttonIndex == 1)
        {
            ShoppingItemEntity* item = [self.shoppingFetchedResultsController objectAtIndexPath: self.cellIndex];
            ChoicesEntity* choice = item.itemsToChoice;
            choice.choiceToItem = nil;
            
            if([alertView.title isEqualToString: @"Item Count is More Than One"])
            {
                NSManagedObject* managed = [self.shoppingFetchedResultsController objectAtIndexPath: self.cellIndex];
                
                [self.managedObjectContext deleteObject:managed];
                [self.managedObjectContext save:nil];
                // [self.tableView deleteRowsAtIndexPaths:@[self.rowIndex] withRowAnimation:UITableViewRowAnimationFade];
                [self loadItemData];
                [self.tableView reloadData];
            }
            else
            {
                [self deleteAllItemData];
            }
        }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        
        [self loadItemData];
        
        // ... and delete all of them, so we have an empty table.
        for (ShoppingItemEntity *item in self.shoppingFetchedResultsController.fetchedObjects)
        {
            if([item.checked isEqual: @1])
            {
                ChoicesEntity* choice = item.itemsToChoice;
                choice.choiceToItem = nil;
                
                [self.managedObjectContext deleteObject:item];
                
            }
        }
        
        [self.managedObjectContext save:nil];
        [self loadItemData];
        [self.tableView reloadData];
    } 
}


-(void)deleteHandler
{
    
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete All Items?" message: @"are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
    [deleteAlert show];
    
}


-(void) loadItemData
{
    
    NSError *error = nil;
    [self.shoppingFetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform student fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    else
    {
        NSLog(@"Number of Items: %lu", (unsigned long)self.shoppingFetchedResultsController.fetchedObjects.count);
    }
    
}




- (NSFetchedResultsController *)shoppingFetchedResultsController
{
    if (_shoppingFetchedResultsController == nil)
    {
        // Initialize Fetch Request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ShoppingItemEntity"];
        
        // Sort first by department abbreviation, and then by course number.
        fetchRequest.sortDescriptors = [NSArray arrayWithObjects:
                                        [NSSortDescriptor sortDescriptorWithKey:@"itemName" ascending:YES],
                                        nil];
        
        // Create the fetched results controller.
        _shoppingFetchedResultsController = [[NSFetchedResultsController alloc]
                                            initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                            sectionNameKeyPath:nil
                                            cacheName:nil];
        
        // The view controller serves as the delegate for the fetched results controller.
        _shoppingFetchedResultsController.delegate = self;
    }
    
    return _shoppingFetchedResultsController;
}

- (void)deleteAllItemData
{
    // Load the existing course records...
    [self loadItemData];
    
    // ... and delete all of them, so we have an empty table.
    for (ShoppingItemEntity *item in self.shoppingFetchedResultsController.fetchedObjects)
    {
        ChoicesEntity* choice = item.itemsToChoice;
        choice.choiceToItem = nil;
        [self.managedObjectContext deleteObject:item];
    }
    
    [self.managedObjectContext save:nil];
    [self loadItemData];
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)choicesFetchedResultsController
{
    if (_choicesFetchedResultsController == nil)
    {
        // Initialize Fetch Request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ChoicesEntity"];
        
        // Sort first by department abbreviation, and then by course number.
        fetchRequest.sortDescriptors = [NSArray arrayWithObjects:
                                        [NSSortDescriptor sortDescriptorWithKey:@"choiceName" ascending:YES],
                                        nil];
        
        // Create the fetched results controller.
        _choicesFetchedResultsController = [[NSFetchedResultsController alloc]
                                            initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                            sectionNameKeyPath:@"choiceSection"
                                            cacheName:nil];
        
        // The view controller serves as the delegate for the fetched results controller.
        _choicesFetchedResultsController.delegate = self;
    }
    
    return _choicesFetchedResultsController;
}

-(void) loadChoicesData
{
    
    NSError *error = nil;
    [self.choicesFetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform student fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    else
    {
        //  NSLog(@"Number of Choices: %lu", (unsigned long)self.choicesFetchedResultsController.fetchedObjects.count);
    }
    
}

-(void) setupDB
{
    NSString* capKey;
    NSString* tempKey;
    
    
    NSEntityDescription *choicesEntity = [NSEntityDescription entityForName:@"ChoicesEntity" inManagedObjectContext:self.managedObjectContext];
    
    NSArray* choicesData = @[@"Apples", @"Produce", @"Bread", @"Baked Goods", @"Butter", @"Dairy", @"Cheese", @"Dairy", @"Eggs", @"Produce", @"Grapes", @"Produce", @"Ice Cream", @"Dairy", @"Milk",
                             @"Dairy", @"Oranges", @"Produce", @"Oreos", @"Snacks and Desserts"];
    
    
    for(int i = 0; i < choicesData.count; i += 2)
    {
        
        ChoicesEntity* choices = [[ChoicesEntity alloc] initWithEntity: choicesEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        choices.choiceName = choicesData[i];
        choices.choiceCategory = choicesData[i+1];
        
        //get and capitalize for section field
        tempKey = [choicesData[i] substringToIndex:1];
        capKey = [tempKey capitalizedString];
        
        choices.choiceSection = capKey;
        
        
        
        
        
    }
    
    NSError *error = nil;
    
    if (![self.managedObjectContext save:&error])
    {
        if (error)
        {
            NSLog(@"Unable to save record.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
        
        // Show Alert View
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your record could not be saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
