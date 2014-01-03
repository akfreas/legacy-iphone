#import "DataSyncUtility.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "PersistenceManager.h"
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
        queue = [[NSOperationQueue alloc] init];
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
    
    NSArray *persons = [Person allPersonsInContext:[[PersistenceManager sharedInstance] managedObjectContext] includePrimary:NO];
    Person *primaryPerson = [Person primaryPersonInContext:nil];
    LegacyAppRequest *request = [LegacyAppRequest requestToSaveFacebookUsers:persons forPerson:primaryPerson];
    
    connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
    
    
    [connection getWithCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
        
        if (completionBlock != NULL) {
            completionBlock();
        }
    }];
}

-(void)parseArrayOfEventsForTable:(NSArray *)events {
    
    PersistenceManager *ourManager = [PersistenceManager new];
    [ourManager deleteObjectsOfType:[EventPersonRelation class] context:nil];
    for (NSDictionary *eventDict in events) {
        [EventPersonRelation relationFromJSON:eventDict context:ourManager.managedObjectContext];
    }
    [ourManager save];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion != NULL) {
            completion();
        }
    });
    [self syncRelatedEvents];
}

-(void)syncRelatedEvents {
    
    NSArray *figures = [Figure allObjects];
    
    if ([figures count] > 0) {
        
        for (Figure *theFigure in figures) {
            LegacyAppRequest *request = [LegacyAppRequest requestToGetAllEventsForFigure:theFigure];
            
            connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
            
            [connection getWithCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
                PersistenceManager *ourManager = [PersistenceManager new];
                NSArray *resultArray = (NSArray *)result;
                for (NSDictionary *relatedEvent in resultArray) {
                    [Event eventFromJSON:relatedEvent context:ourManager.managedObjectContext];
                }
                [ourManager save];
            }];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:KeyForLastDateSynced];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
