#import "SwitchPerson.h"
#import "AddNewPerson.h"
#import "Utility_UserInfo.h"


static NSString *KeyForName = @"name";
static NSString *KeyForBirthday = @"birthday";


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
        names = [Utility_UserInfo arrayOfUserInfo];        
        name = [Utility_UserInfo nameFromUserDefaults];
        birthday = [Utility_UserInfo birthdayFromUserDefaults];
        
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSDictionary *userInfo = [names objectAtIndex:indexPath.row];
    
    NSString *labelForName = [[userInfo allKeys] objectAtIndex:0];
    NSString *labelForBirthday = [formatter stringFromDate:[userInfo objectForKey:labelForName]];
    
    NSLog(@"Birthday: %@", [[userInfo objectForKey:labelForName] class]);
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = labelForName;
    cell.detailTextLabel.text = labelForBirthday;
    
    if ([labelForName isEqualToString:[Utility_UserInfo nameFromUserDefaults]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        pathForSelectedCell = indexPath;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    name = [[names objectAtIndex:indexPath.row] objectForKey:KeyForName];
    birthday = [[names objectAtIndex:indexPath.row] objectForKey:KeyForBirthday];
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:pathForSelectedCell];
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    pathForSelectedCell = indexPath;
}

-(void)doneWasTapped {
    
    [Utility_UserInfo setNameInUserDefaults:name birthday:birthday];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addName {
    
    AddNewPerson *newPersonController = [[AddNewPerson alloc] init];
    
    [self.navigationController pushViewController:newPersonController animated:YES];
}

-(void)configureNavigationBarItems {
    
    self.navigationItem.title = @"Select Another Name";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWasTapped)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addName)];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    names = [Utility_UserInfo arrayOfUserInfo];        
    [self.tableView reloadData];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationBarItems];
}


  
@end