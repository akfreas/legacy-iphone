#import "FriendPickerHandler.h"
#import "ObjectArchiveAccessor.h"

@implementation FriendPickerHandler {
    
    NSMutableArray *selectedFriends;
    ObjectArchiveAccessor *accessor;
}

-(id)init {
    
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

-(FBModalCompletionHandler)completionHandler {
    return (FBModalCompletionHandler)^(FBFriendPickerViewController *sender, BOOL donePressed){
        if (donePressed) {
            accessor = [ObjectArchiveAccessor sharedInstance];
            NSLog(@"New users: %@", [accessor addFacebookUsers:sender.selection]);
            [accessor save];
            [sender dismissViewControllerAnimated:YES completion:^{
            }];
        } else {
            [sender dismissViewControllerAnimated:YES completion:NULL];
        }
    };
}

-(void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker {
}


@end
