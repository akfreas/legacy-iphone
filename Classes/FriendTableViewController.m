#import "FriendTableViewController.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"

@implementation FriendTableViewController {
    
    ObjectArchiveAccessor *accessor;
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
            Person *user = [persons objectAtIndex:indexPath.row];
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
        retVal = [persons count];
    }
    return retVal;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Person *personToDelete = [persons objectAtIndex:indexPath.row];
        [accessor removePerson:personToDelete];
        persons = [accessor allPersons];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [tableView reloadData];
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

@end