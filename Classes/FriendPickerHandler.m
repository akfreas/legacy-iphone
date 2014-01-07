#import "FriendPickerHandler.h"
#import "DataSyncUtility.h"
#import "Person.h"
#import "BirthdaySelectionView.h"
#import "PersistenceManager.h"
#import "LegacyAppConnection.h"
#import "LegacyAppRequest.h"
#import <RNBlurModalView/RNBlurModalView.h>

@implementation FriendPickerHandler {
    
    NSMutableDictionary *selectedFriends;
    RNBlurModalView *blurView;
    BirthdaySelectionView *enterBirthdayView;
}

@synthesize friendPickerCompletionBlock;
-(id)init {
    self = [super init];
    if (self) {
        selectedFriends = [NSMutableDictionary dictionary];
    }
    return self;
}

-(FBModalCompletionHandler)completionHandler {
    return (FBModalCompletionHandler)^(FBFriendPickerViewController *sender, BOOL donePressed){
        if (donePressed) {
                [[DataSyncUtility sharedInstance] syncFacebookFriends:^{
                    [sender dismissViewControllerAnimated:YES completion:NULL];
                    [[DataSyncUtility sharedInstance] sync:NULL];
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
                void(^cancelledBlock)() = ^(){
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
                enterBirthdayView.cancelButtonBlock = cancelledBlock;
                enterBirthdayView.okButtonBlock = ^(id<FBGraphUser> graphUser){
                    [Person personWithFacebookGraphUser:graphUser inContext:nil];
                    [friendPicker.tableView reloadData];
                    [aBlurView hide];
                };
                blurView = aBlurView;
            } else {
                [Person personWithFacebookGraphUser:user inContext:nil];
            }
            [selectedFriends setValue:user forKey:user.id];
        }
        [diffDict removeObjectForKey:user.id];
    }
    if ([diffDict count] > 0) {
        for (NSString *fbUserID in diffDict.allKeys) {
            [selectedFriends removeObjectForKey:fbUserID];
            Person *person = [Person personWithFacebookID:fbUserID context:nil];
            if (person != nil) {
                [self removePerson:person];
            }
        }
    }
    
}

-(void)removePerson:(Person *)person {
    LegacyAppRequest *request = [LegacyAppRequest requestToDeletePerson:person];
    LegacyAppConnection *connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
    NSManagedObjectID *personID = person.objectID;
    [connection getWithCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
        if (error == nil) {
            PersistenceManager *ourManager = [PersistenceManager new];
            Person *ourPerson = [Person objectWithObjectID:personID inContext:ourManager.managedObjectContext];
            [ourPerson delete];
            [ourManager save];
        }
    }];
}

@end
