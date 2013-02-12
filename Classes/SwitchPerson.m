#import "SwitchPerson.h"
#import "AddNewPerson.h"
#import "Utility_PersonInfo.h"
#import "SwitchPersonCell.h"

@implementation SwitchPerson {
    
    NSArray *names;
    NSString *name;
    NSDate *birthday;
    NSDateFormatter *formatter;
    
    NSIndexPath *pathForSelectedCell;
}



-(id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/YYYY"];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [names count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"cellIdentifier";
    
    SwitchPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSDictionary *userInfo = [names objectAtIndex:indexPath.row];
    
    NSString *labelForName = [[userInfo allKeys] objectAtIndex:0];
    NSString *labelForBirthday = [formatter stringFromDate:[userInfo objectForKey:labelForName]];
    
    NSLog(@"Birthday: %@", [[userInfo objectForKey:labelForName] class]);
    
    if (cell == nil) {
        
        cell = [[SwitchPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell configureCellWithName:labelForName birthday:labelForBirthday];
    if ([labelForName isEqualToString:[Utility_PersonInfo currentName]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        pathForSelectedCell = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    name = [[[names objectAtIndex:indexPath.row] allKeys] objectAtIndex:0];
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:pathForSelectedCell];
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    pathForSelectedCell = indexPath;
}

-(void)doneWasTapped {
    
    [Utility_PersonInfo setCurrentName:name];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addName {
    
    AddNewPerson *newPersonController = [[AddNewPerson alloc] init];
    
    [self.navigationController pushViewController:newPersonController animated:YES];
}

-(void)configureNavigationBarItems {
    
    self.navigationItem.title = @"Select Name";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWasTapped)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addName)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    names = [Utility_PersonInfo arrayOfPersonInfo];        
    name = [Utility_PersonInfo currentName];
    birthday = [Utility_PersonInfo birthdayForCurrentName];

    [self.tableView reloadData];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationBarItems];
}


  
@end