#import "FriendPickerHandler.h"
#import "ObjectArchiveAccessor.h"
#import "DataSyncUtility.h"

@implementation FriendPickerHandler {
    
    NSMutableArray *selectedFriends;
    ObjectArchiveAccessor *accessor;
}

@synthesize friendPickerCompletionBlock;

-(FBModalCompletionHandler)completionHandler {
    return (FBModalCompletionHandler)^(FBFriendPickerViewController *sender, BOOL donePressed){
        if (donePressed) {
            accessor = [ObjectArchiveAccessor sharedInstance];
            __unsafe_unretained typeof(self) weakSelf = self;
            [accessor addFacebookUsers:sender.selection completionBlock:^{
                [[DataSyncUtility sharedInstance] syncFacebookFriends:^{
                    [weakSelf useCompletion];
                }];

            }];
            [sender dismissViewControllerAnimated:YES completion:NULL];
        } else {
            [sender dismissViewControllerAnimated:YES completion:NULL];
        }
    };
}

-(void)useCompletion{
    friendPickerCompletionBlock();
}

-(void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker {
}



@end
