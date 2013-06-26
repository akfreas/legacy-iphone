#import "FriendTableViewController.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"

@implementation FriendTableViewController {
    
    ObjectArchiveAccessor *accessor;
    NSFetchedResultsController *fetchedResultsController;
    NSArray *persons;
}

#define AddFriendsCellId  @"AddFriendsCell"
#define FriendCellId  @"FriendCell"
#define AddFriendTableSection 0
#define FriendTableSection 1



-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        accessor = [ObjectArchiveAccessor sharedInstance];
        fetchedResultsController = [accessor fetchedResultsControllerForRelations];
        fetchedResultsController.delegate = self;

        persons = [accessor allPersons];
        UINib *nib = [UINib nibWithNibName:@"AddFriendsCell" bundle:[NSBundle mainBundle]];
        [self.tableView registerNib:nib forCellReuseIdentifier:AddFriendsCellId];
    }
    return self;
}

-(void)reload {
    persons = [accessor allPersons];
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSArray *cellIds;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellIds = [[NSArray alloc] initWithObjects:AddFriendsCellId, FriendCellId, nil];
    });
    
    NSString *cellId = [cellIds objectAtIndex:indexPath.section];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        if ([cellId isEqualToString:FriendCellId]) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.textLabel.text = @"Test";
            Person *user = [fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        } 
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
    NSInteger retVal;
    if (section == AddFriendTableSection) {
        retVal = 1;
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:0];

        retVal = [sectionInfo numberOfObjects];
    }
    NSLog(@"Persons: %@", persons);
    NSLog(@"Retval: %d", retVal);
    return retVal;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Person *personToDelete = [persons objectAtIndex:indexPath.row];
        [accessor removePerson:personToDelete];
        persons = [accessor allPersons];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == AddFriendTableSection) {
        if (self.addFriendBlock != NULL) {
            self.addFriendBlock();
        }
    } else if (indexPath.section == FriendTableSection) {
        if (self.personSelectedBlock != NULL) {
            Person *selectedPerson = [persons objectAtIndex:indexPath.row];
            self.personSelectedBlock(selectedPerson);
        }
    }
}

#pragma mark UIViewController methods 

-(void)viewDidLoad {
    [super viewDidLoad];
    NSError *error;
    [fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Error fetching %@", error);
    }
}

#pragma mark NSFetchedResultsControllerDelegate methods

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:FriendTableSection]] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
    
    NSLog(@"Object: %@, FetchedChangeType: %d, IndexPath: %@", anObject, type, newIndexPath);
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    [self.tableView reloadData];
}

@end