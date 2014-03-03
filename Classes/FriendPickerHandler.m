#import "FriendPickerHandler.h"
#import "DataSyncUtility.h"
#import "Person.h"
#import "BirthdaySelectionView.h"

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
            [sender dismissViewControllerAnimated:YES completion:NULL];
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
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
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
                __weak FriendPickerHandler *instance = self;
                enterBirthdayView.okButtonBlock = ^(id<FBGraphUser> graphUser){
                    [instance addPersonWithGraphUser:graphUser];
                    [friendPicker.tableView reloadData];
                    [aBlurView hide];
                };
                blurView = aBlurView;
            } else {
                [self addPersonWithGraphUser:user];
            }
            [selectedFriends setValue:user forKey:user.id];
        }
        [diffDict removeObjectForKey:user.id];
    }
    if ([diffDict count] > 0) {
        for (NSString *fbUserID in diffDict.allKeys) {
            [selectedFriends removeObjectForKey:fbUserID];
            Person *person = [Person personWithFacebookID:fbUserID context:context];
            if (person != nil) {
                [self removePerson:person];
            }
        }
    }
}

-(void)addPersonWithGraphUser:(id<FBGraphUser>)user {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context performBlockAndWait:^{
        __block Person *newPerson = [Person personWithFacebookGraphUser:user inContext:context];
        [context MR_saveOnlySelfAndWait];
        LegacyAppRequest *request = [LegacyAppRequest requestToAddPerson:newPerson];
        
        [LegacyAppConnection get:request withCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
            LegacyAppRequest *relationRequest = [LegacyAppRequest requestToGetEventForPerson:newPerson];
            [LegacyAppConnection get:relationRequest withCompletionBlock:^(LegacyAppRequest *request, NSDictionary *relation, NSError *error) {
                NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
                [ctx performBlock:^{
                    [EventPersonRelation relationFromJSON:relation context:ctx];
                    [ctx MR_saveOnlySelfAndWait];
                }];
            }];
        }];
    }];
}

-(void)removePerson:(Person *)person {
    
    [EventPersonRelation MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"person == %@", person]];
    
    LegacyAppRequest *request = [LegacyAppRequest requestToDeletePerson:person];
    NSManagedObjectID *personID = person.objectID;
    [LegacyAppConnection get:request withCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
        NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
        [ctx performBlockAndWait:^{
            Person *ourPerson = [Person objectWithObjectID:personID inContext:ctx];
            [ourPerson MR_deleteInContext:ctx];
            [ctx MR_saveOnlySelfAndWait];
        }];
    }];
}

@end
