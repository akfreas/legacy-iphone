@class Person;
@interface FriendTableViewController : UITableViewController <FBFriendPickerDelegate>

@property (copy) void(^addFriendBlock)();
@property (copy) void(^personSelectedBlock)(Person *selectedPerson);

-(void)reload;

@end
