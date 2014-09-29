//
//  PDCustomersTableController.h
//  KodakLensIDS
//
//  Created by Oleg Bogatenko on 27/01/2014.
//
//

#import <UIKit/UIKit.h>

@protocol PDCustomersTableControllerDelegate<NSObject>

@optional
- (void)PopoverDidSelectRowAtIndex:(NSInteger)index;
- (void)dismissPopover;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface PDCustomersTableController : UITableViewController
{
    NSArray *customersArray;
}

@property (nonatomic, assign) id <PDCustomersTableControllerDelegate> delegate;

@property (nonatomic, weak) NSNetService *service;

- (id)initWithCustomersArray:(NSArray *)customers;

@end
