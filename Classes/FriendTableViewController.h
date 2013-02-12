@interface FriendTableViewController : UITableViewController <FBFriendPickerDelegate>

@property (copy) void(^addFriendBlock)();
@property (copy) void(^friendSelectedBlock)();

@end
