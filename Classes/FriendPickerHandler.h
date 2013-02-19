@interface FriendPickerHandler : NSObject <FBFriendPickerDelegate>

-(FBModalCompletionHandler)completionHandler;

@property (copy) void(^friendPickerCompletionBlock)();

@end
