//
//  MainViewController.m
//  TestAppBigDig
//
//  Created by  ZHEKA on 17.05.16.
//  Copyright © 2016  ZHEKA. All rights reserved.
//

#import "MainViewController.h"
#import "DataManager.h"
#import "NewSellViewController.h"
#import "ExampleOfCell.h"
#import "LongCellTableViewCell.h"
#import "Product.h"
#import "Product+CoreDataProperties.h"

@interface MainViewController () <UISearchBarDelegate, ReloadViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *seachBar;

@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSIndexPath *indexPath;

- (IBAction)addNew:(UIButton *)sender;

@end

@implementation MainViewController

@synthesize fetchedResultsController = _fetchedResultsController;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
    [self.seachBar setBackgroundImage:[[UIImage alloc] init]];

    self.images = [[NSMutableArray alloc] init];
    self.indexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];

}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources thavt can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (_fetchedResultsController != nil) {

        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *nameDescription = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[nameDescription]];
    
    if (![self.seachBar.text isEqualToString:@""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@", self.seachBar.text];
        
        [fetchRequest setPredicate:predicate];
    }
        
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.images removeAllObjects];
    
    NSArray *imagesArr = [self.fetchedResultsController fetchedObjects];
    NSArray *arr = [imagesArr valueForKeyPath:@"@unionOfObjects.images"];
    
    for (NSData *data in arr) {
        NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        UIImage *firstIm = [array firstObject];
        CGFloat compression = 0.0001f;
        CGFloat maxCompression = 0.00001f;
        int maxFileSize = 50;
        
        NSData *imageData = UIImageJPEGRepresentation(firstIm, compression);
        
        while ([imageData length] > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1;
            imageData = UIImageJPEGRepresentation(firstIm, compression);
        }
        
        [self.images addObject:[UIImage imageWithData:imageData]];
    }
    
    return _fetchedResultsController;
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Product *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (self.indexPath.row == indexPath.row && self.indexPath.section == indexPath.section) {
        
        LongCellTableViewCell *examplCell = (LongCellTableViewCell*) cell;
        
        [examplCell.imageMainView setImage:[self.images objectAtIndex:indexPath.item]];
        examplCell.priceLabel.text = [NSString stringWithFormat:@"$ %@",[product.price stringValue]];
        examplCell.nameLabel.text = product.name;
        examplCell.desctiptionTextView.text = product.info;

        NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:product.images];
        examplCell.allPhotosArray = array;
        [examplCell.photoControl setNumberOfPages:[array count]];
        
        return;
    }
    
    ExampleOfCell *examplCell = (ExampleOfCell*) cell;
    
    
    examplCell.imageViewFromSell.image = nil;
    [examplCell.imageViewFromSell setImage:[self.images objectAtIndex:indexPath.item]];
    examplCell.priceLabel.text = [NSString stringWithFormat:@"$ %@",[product.price stringValue]];
    examplCell.nameLabel.text = product.name;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.indexPath.row && indexPath.section == self.indexPath.section) {
        return 520.0;
    } else {
        return 117.0;
    }
}

#pragma mark - UITableViewDelegateSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.indexPath.row == indexPath.row && indexPath.section == indexPath.section) {
        self.indexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    } else {
        
        self.indexPath = indexPath;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
    

}

- (NSManagedObjectContext*) managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[DataManager sharedManager] managedObjectContext];
    }
    
    return _managedObjectContext;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *identifier = @"FirstPageExampleIdentifier";
    static NSString *hardIdent = @"MyHardIdentifier";
    
    
    ExampleOfCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = (ExampleOfCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    if (self.indexPath.row == indexPath.row && self.indexPath.section == indexPath.section) {
        cell = [tableView dequeueReusableCellWithIdentifier:hardIdent];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        [self deleteObjectAtIndexPath:indexPath];
    }
}

- (void) deleteObjectAtIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}



#pragma mark - Fetched results controller

//- (NSFetchedResultsController *)fetchedResultsController
//{
//    return nil;
//}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark Search bar delegate

// Begin to edit text on search bar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:YES animated:YES ];
}

// Finish to edit text on search bar
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES ];
}

// Search button is clicked
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    [self reloadFirstPageView];
}

// Cancel button is clicked
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];

    if ([searchBar.text isEqualToString:@""] && [[_fetchedResultsController fetchedObjects] count] == 0) {
        [self reloadFirstPageView];
    }
    
    searchBar.text = @"";
}

- (IBAction)addNew:(UIButton *)sender {

    NewSellViewController *newSellVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewSellViewController"];
    newSellVC.delegate = self;
    [self presentViewController:newSellVC animated:YES completion:nil];
}

#pragma mark - ReloadViewDelegate - reload own cells

-(void) reloadFirstPageView {
    
    _fetchedResultsController = nil;
    [self.tableView reloadData];
}

#pragma mark - Actions Delete and Change -

- (IBAction)deleteAction:(UIButton *)sender {
    
    
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:self.indexPath.row inSection:self.indexPath.section];
    self.indexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self deleteObjectAtIndexPath:rowToReload];
    
}

- (IBAction)editAction:(UIButton *)sender {
    
    NewSellViewController *newSellVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewSellViewController"];
    newSellVC.delegate = self;
    newSellVC.product = [_fetchedResultsController objectAtIndexPath:self.indexPath];
    self.fetchedResultsController = nil;
    [self presentViewController:newSellVC animated:YES completion:nil];
    
}

@end
