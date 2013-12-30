#import "FriendPickerHandler.h"
#import "ObjectArchiveAccessor.h"
#import "DataSyncUtility.h"
#import "Person.h"

@implementation FriendPickerHandler {
    
    NSMutableArray *selectedFriends;
    ObjectArchiveAccessor *accessor;
}

@synthesize friendPickerCompletionBlock;
-(id)init {
    self = [super init];
    if (self) {
        accessor = [ObjectArchiveAccessor sharedInstance];
    }
    return self;
}

-(FBModalCompletionHandler)completionHandler {
    return (FBModalCompletionHandler)^(FBFriendPickerViewController *sender, BOOL donePressed){
        if (donePressed) {
            [accessor addFacebookUsers:sender.selection completionBlock:^{
                [[DataSyncUtility sharedInstance] syncFacebookFriends:^{
                    [sender dismissViewControllerAnimated:YES completion:NULL];
                    [[DataSyncUtility sharedInstance] sync:NULL];
                }];

            }];
        } else {
            [sender dismissViewControllerAnimated:YES completion:NULL];
        }
    };
}

-(void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker {
    

}



@end
