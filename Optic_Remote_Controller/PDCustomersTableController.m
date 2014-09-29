//
//  PDCustomersTableController.m
//  KodakLensIDS
//
//  Created by Oleg Bogatenko on 27/01/2014.
//
//

#import "PDCustomersTableController.h"




@implementation PDCustomersTableController

@synthesize delegate;

- (id)initWithCustomersArray:(NSArray *)customers
{
    self = [super init];
    
    if (self)
    {
        customersArray = [NSArray arrayWithArray:customers];
        NSLog(@" CUSTOMERS - %@", customersArray);
        self.contentSizeForViewInPopover = CGSizeMake(300, 400);
        [self.tableView reloadData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Available Devices", @"");
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed)];
    
    [self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
    
   // [self.tableView registerNib:[UINib nibWithNibName:@"cell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [customersArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    static NSString *CellIdentifier = @"cell";
    
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSNetService *service = [customersArray objectAtIndex:[indexPath row]];
    
    // Configure Cell
    [cell.textLabel setText:[service name]];
    NSLog(@"The name of cell was added - %@\n",[service name]);
    
    
    return cell;

    
}

- (void)cancelButtonPressed
{
    if (delegate && [delegate respondsToSelector:@selector(dismissPopover)])
    {
        [delegate dismissPopover];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (delegate && [delegate respondsToSelector:@selector(PopoverDidSelectRowAtIndex:)])
    {
        [delegate PopoverDidSelectRowAtIndex:indexPath.row];
    }
}

@end
