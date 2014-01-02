#import "FriendPickerHandler.h"
#import "ObjectArchiveAccessor.h"
#import "DataSyncUtility.h"
#import "Person.h"
#import "BirthdaySelectionView.h"
#import <RNBlurModalView/RNBlurModalView.h>

@implementation FriendPickerHandler {
    
    NSMutableDictionary *selectedFriends;
    ObjectArchiveAccessor *accessor;
    RNBlurModalView *blurView;
    BirthdaySelectionView *enterBirthdayView;
}

@synthesize friendPickerCompletionBlock;
-(id)init {
    self = [super init];
    if (self) {
        selectedFriends = [NSMutableDictionary dictionary];
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

-(void)setFriendPickerControllerSelection:(NSArray *)friendPickerControllerSelection {
    _friendPickerControllerSelection = friendPickerControllerSelection;
    for (id<FBGraphUser> user in friendPickerControllerSelection) {
        [selectedFriends setValue:user forKey:user.id];
    }
}

-(void)friendPickerViewControllerSelectionWillChange:(FBFriendPickerViewController *)friendPicker {
    for (id<FBGraphUser> user in friendPicker.selection) {
        if ([selectedFriends objectForKey:user.id] == nil) {
            [selectedFriends setValue:user forKey:user.id];
        }
    }
}

-(void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker {
    NSMutableDictionary *diffDict = [NSMutableDictionary dictionaryWithDictionary:selectedFriends];
    
    
    for (id<FBGraphUser> user in friendPicker.selection) {
        if ([selectedFriends objectForKey:user.id] == nil) {
            if ([[Utility_AppSettings dateFormatterForDisplay] dateFromString:user.birthday] == nil) {
                if (enterBirthdayView == nil) {
                    enterBirthdayView = [[BirthdaySelectionView alloc] initForAutoLayout];
                }
                enterBirthdayView.facebookUser = user;
                blurView = [[RNBlurModalView alloc] initWithParentView:friendPicker.view view:enterBirthdayView];

//                [blurView hideCloseButton:YES];
                [blurView show];
            }
            [selectedFriends setValue:user forKey:user.id];
            [diffDict removeObjectForKey:user.id];
        }
    }
    if ([diffDict count] > 0) {
        for (NSString *fbUserID in diffDict.allKeys) {
            [selectedFriends removeObjectForKey:fbUserID];
        }
    }
    
}

@end
