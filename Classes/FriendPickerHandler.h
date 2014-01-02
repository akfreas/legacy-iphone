@interface FriendPickerHandler : NSObject <FBFriendPickerDelegate>

-(FBModalCompletionHandler)completionHandler;

@property (copy) void(^friendPickerCompletionBlock)();
@property (nonatomic, strong) NSArray *friendPickerControllerSelection;
@end
