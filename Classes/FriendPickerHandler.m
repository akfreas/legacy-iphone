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
                RNBlurModalView *aBlurView = [[RNBlurModalView alloc] initWithParentView:friendPicker.view view:enterBirthdayView];

                [aBlurView hideCloseButton:YES];
                [aBlurView show];
                void(^pickedBlock)(NSDate *) = ^(NSDate *pickedDate){
                    NSMutableArray *oldArray = [NSMutableArray arrayWithArray:friendPicker.selection];
                    NSInteger idx = [oldArray indexOfObjectPassingTest:^BOOL(id<FBGraphUser> sortedUser, NSUInteger idx, BOOL *stop) {
                        if (sortedUser.id == user.id) {
                            return YES;
                        } else {
                            return NO;
                        }
                    }];
                    if (idx != NSNotFound) {
                        [selectedFriends removeObjectForKey:[oldArray[idx] id]];
                        [oldArray removeObjectAtIndex:idx];
                        [friendPicker clearSelection];
                        friendPicker.selection = oldArray;
                    }
                    [aBlurView hide];
                };
                enterBirthdayView.cancelButtonBlock = pickedBlock;
                enterBirthdayView.okButtonBlock = ^{
                    [aBlurView hide];
                };
                blurView = aBlurView;
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
