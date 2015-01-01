//
//  AddChoiceViewController.m
//  Shopping_Portokalis_Christopher
//
//  Created by PORTOKALIS CHRISTOPHER G on 10/2/14.
//  Copyright (c) 2014 PORTOKALIS CHRISTOPHER G. All rights reserved.
//

#import "AddChoiceViewController.h"

@interface AddChoiceViewController ()


@property BOOL textInChoice;
@property BOOL textInCategory;
@property (weak, nonatomic) IBOutlet UIButton *saveChoiceButton;

@end

@implementation AddChoiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)didEditText:(id)sender {
    
    NSString* choiceText = [self.addChoiceField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString* catText = [self.addCategoryField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(![catText isEqualToString:@""] && ![choiceText isEqualToString:@""])
    {
        
        self.saveChoiceButton.enabled = true;
        
    }
    else
    {
        self.saveChoiceButton.enabled = false;
    }
    
    
    
}
- (IBAction)resignTextField:(id)sender {
    
    [sender resignFirstResponder];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.saveChoiceButton.enabled = false;
    self.textInChoice = false;
    self.textInCategory = false;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelAddChoice:(id)sender {
    
    
    [self.navigationController popViewControllerAnimated: YES];
    
}




@end
