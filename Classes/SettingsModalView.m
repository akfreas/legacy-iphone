#import "SettingsModalView.h"

static NSString *identifier = @"Cell";

@implementation SettingsModalView {
    
    NSArray *cellArray;
}



-(id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        [self setCellArray];
    }
    
    return self;
}


-(UITableViewCell *)cellForEnableDisableNotifications {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UISwitch *theSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 9, 79, 27)];
    
    [cell addSubview:theSwitch];
    cell.textLabel.text = @"Notify me daily";
    return cell;
}

-(void)setCellArray {
    cellArray = [NSArray arrayWithObjects:[self cellForEnableDisableNotifications], nil];
}

-(void)doneWasTapped {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)configureNavigationItems {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWasTapped)];
    self.navigationItem.title = @"Settings";
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [cellArray objectAtIndex:indexPath.row];
    }
    
    return cell;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationItems];
}

@end
