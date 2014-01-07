#import "DataSyncUtility.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "Figure.h"
#import "Event.h"
#import "Person.h"

@implementation DataSyncUtility {
    
    NSOperationQueue *queue;
    LegacyAppConnection *connection;
    void (^completion)();
}

+(DataSyncUtility *)sharedInstance {
    static dispatch_once_t onceToken;
    static DataSyncUtility *instance;
    if (instance == nil) {
        dispatch_once(&onceToken, ^{
            instance = [[DataSyncUtility alloc] init];
        });
    }
    return instance;
}

-(id)init {
    self = [super init];
    
    if (self) {
        connection = [[LegacyAppConnection alloc] initWithLegacyRequest:nil];
    }
    return self;
}

-(void)sync:(void (^)())completionBlock {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    LegacyAppRequest *request;
    completion = completionBlock;
    Person *primaryPerson = [Person primaryPersonInContext:nil];

    request = [LegacyAppRequest requestToGetStoriesForPerson:primaryPerson];
    
    connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
    
    [connection getWithCompletionBlock:^(LegacyAppRequest *request, NSArray *result, NSError *error) {
        [self parseArrayOfEventsForTable:result];
    }];
    
}

-(void)syncFacebookFriends:(void(^)())completionBlock {
    
    NSArray *persons = [Person MR_findAll];
    Person *primaryPerson = [Person MR_findFirstByAttribute:@"isPrimary" withValue:[NSNumber numberWithBool:YES]];
    LegacyAppRequest *request = [LegacyAppRequest requestToSaveFacebookUsers:persons forPerson:primaryPerson];
    
    connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
    
    
    [connection getWithCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
        
        if (completionBlock != NULL) {
            completionBlock();
        }
    }];
}

-(void)parseArrayOfEventsForTable:(NSArray *)events {
    
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_contextForCurrentThread];
    [ctx performBlock:^{
        [EventPersonRelation MR_deleteAllMatchingPredicate:nil inContext:ctx];
        for (NSDictionary *eventDict in events) {
            [EventPersonRelation relationFromJSON:eventDict context:ctx];
        }
        [ctx MR_saveOnlySelfAndWait];
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion != NULL) {
            completion();
        }
    });
    [self syncRelatedEvents];
}

-(void)syncRelatedEvents {
    
    NSArray *figures = [Figure MR_findAll];
    
    if ([figures count] > 0) {
        
        for (Figure *theFigure in figures) {
            LegacyAppRequest *request = [LegacyAppRequest requestToGetAllEventsForFigure:theFigure];
            
            
            [connection get:request withCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
                NSArray *resultArray = (NSArray *)result;
                NSManagedObjectContext *ctx = [NSManagedObjectContext MR_contextForCurrentThread];
                [ctx performBlock:^{
                    
                    for (NSDictionary *relatedEvent in resultArray) {
                        [Event eventFromJSON:relatedEvent context:ctx];
                    }
                    [ctx MR_saveOnlySelfAndWait];
                }];
            }];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:KeyForLastDateSynced];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
