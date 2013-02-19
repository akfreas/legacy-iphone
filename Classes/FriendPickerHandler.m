#import "FriendPickerHandler.h"
#import "ObjectArchiveAccessor.h"

@implementation FriendPickerHandler {
    
    NSMutableArray *selectedFriends;
    ObjectArchiveAccessor *accessor;
}

@synthesize friendPickerCompletionBlock;

-(FBModalCompletionHandler)completionHandler {
    return (FBModalCompletionHandler)^(FBFriendPickerViewController *sender, BOOL donePressed){
        if (donePressed) {
            accessor = [ObjectArchiveAccessor sharedInstance];
            [accessor addFacebookUsers:sender.selection];
            friendPickerCompletionBlock();
            [sender dismissViewControllerAnimated:YES completion:NULL];
        } else {
            [sender dismissViewControllerAnimated:YES completion:NULL];
        }
    };
}

-(void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker {
}



@end
