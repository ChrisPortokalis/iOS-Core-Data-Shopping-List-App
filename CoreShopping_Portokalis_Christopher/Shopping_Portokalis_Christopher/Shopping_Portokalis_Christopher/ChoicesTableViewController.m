//
//  ChoicesTableViewController.m
//  Shopping_Portokalis_Christopher
//
//  Created by PORTOKALIS CHRISTOPHER G on 10/2/14.
//  Copyright (c) 2014 PORTOKALIS CHRISTOPHER G. All rights reserved.
//

#import "ChoicesTableViewController.h"
#import "ShoppingListViewController.h"
#import "AddChoiceViewController.h"
#import "ChoicesEntity.h"
#import "ShoppingItemEntity.h"
#import "AppDelegate.h"

@interface ChoicesTableViewController () <NSFetchedResultsControllerDelegate>
    @property BOOL firstTime;
    @property UITableView* prevView;

    @property (strong, nonatomic) AppDelegate* appDel;
    @property (strong, nonatomic) NSFetchedResultsController *choicesFetchedResultsController;
    @property (strong, nonatomic) NSFetchedResultsController *shoppingFetchedResultsController;
    @property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation ChoicesTableViewController

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
    self.prevView = self.prevTView;
    
    self.appDel = [UIApplication sharedApplication].delegate;
    [super viewDidLoad];
   
    
    self.managedObjectContext = self.appDel.managedObjectContext;
    self.shoppingFetchedResultsController = self.shoppingViewFetch;
    
  
   [self loadChoicesData];
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   //return self.sortedSections.count;
    
    //for testing
    /*if(self.choicesFetchedResultsController.fetchedObjects.count == 0)
    {
        [self setupDB];
        [self loadChoicesData];
    }*/
    
    return self.choicesFetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSString* key = self.sortedSections[section];
    //NSArray* temp = self.combined[key];

   // return  [temp count];
    return [self.choicesFetchedResultsController.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    ChoicesEntity *item = [self.choicesFetchedResultsController objectAtIndexPath:indexPath];
    static NSString *CellIdentifier = @"choicesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    cell.textLabel.text = item.choiceName;
    cell.detailTextLabel.text = item.choiceCategory;
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    //return self.sortedSections[section];
    return [self.choicesFetchedResultsController.sections[section] name];
}

-(IBAction) getUnwind: (UIStoryboardSegue*) segue
{
    //get entity object for core data

    
    //get source view controller from unwind segue
    AddChoiceViewController *sourceVC = segue.sourceViewController;

    //capitalize and trim text field text and section name
    NSString* newSection = [sourceVC.addChoiceField.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    newSection = [newSection substringToIndex:1];
    newSection = [newSection capitalizedString];

    NSString* newName = [[sourceVC.addChoiceField.text capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* newCat = [[sourceVC.addCategoryField.text capitalizedString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
     bool isInDB = false;
    
    //check if itemName is not already in DB
    for(ChoicesEntity* choices in self.choicesFetchedResultsController.fetchedObjects)
    {
        if([choices.choiceName isEqualToString:newName])
        {
            isInDB = true;
            break;
        }
        
    }

    

    //save object
    if(!isInDB)
    {
        NSEntityDescription *choiceEntity = [NSEntityDescription entityForName:@"ChoicesEntity" inManagedObjectContext:self.managedObjectContext];
        //choices object to add to DB
        ChoicesEntity* choices = [[ChoicesEntity alloc] initWithEntity: choiceEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        //define fields for choice object
        choices.choiceName = newName;
        choices.choiceCategory = newCat;
        choices.choiceSection = newSection;
        
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
    //reload choices and data for table
    [self loadChoicesData];
    [self.tableView reloadData];

    
}


-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSManagedObject* managed = [self.choicesFetchedResultsController objectAtIndexPath:indexPath];

    ChoicesEntity *item = [self.managedObjectContext objectWithID: [managed objectID]];
    
    self.segChoice = item;
    self.segChoiceName = item.choiceName;
    
    //NSLog(choices.choiceName);
    
    [self performSegueWithIdentifier:@"choiceSeg" sender:self];
}




// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


 //Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObject *managedObject = [self.choicesFetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:managedObject];
        [self.managedObjectContext save:nil];
        [self loadChoicesData];
        [self loadItemData];
        [self.tableView reloadData];
        [self.prevView reloadData];
        

        
    } else {
        NSLog(@"Unhandled editing style! %ld", editingStyle);
    }
}


//***************************************************
//added core data functions                         *
//***************************************************



//--------------------------------------
//load fetched results for choices
//-------------------------------------


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



//------------------------------------------------------------------------
//override fetched results controller
//-------------------------------------------------------------------------


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


- (void)deleteAllChoiceData
{
    // Load the existing course records...
    [self loadChoicesData];
    
    // ... and delete all of them, so we have an empty table.
    for (ChoicesEntity *choice in self.choicesFetchedResultsController.fetchedObjects)
    {
        
        [self.managedObjectContext deleteObject:choice];
    }
    
    [self.managedObjectContext save:nil];
}


-(void)deleteChoiceName: (NSString*) delChoiceName
{
    
    //[self loadChoicesData];
    
    
    for(ChoicesEntity *choice in self.choicesFetchedResultsController.fetchedObjects)
    {
       // NSLog(@"Searching for string");
       if([choice.choiceName isEqualToString: delChoiceName])
       {
           [self.managedObjectContext deleteObject: choice];
           [self.managedObjectContext save:nil];
           break;
       }
        
        
        
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



#pragma mark - Navigation







@end
