#import "DataSyncUtility.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "PersistenceManager.h"
#import "Figure.h"
#import "Event.h"
#import "Person.h"

@interface DataSyncUtility ()

@property (copy) void(^completion)();

@end

@implementation DataSyncUtility {
    LegacyAppConnection *connection;
}

@synthesize completion;

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
    self.completion = completionBlock;
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
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    }];
}

-(void)parseArrayOfEventsForTable:(NSArray *)events {
    
    PersistenceManager *ourManager = [PersistenceManager new];
    [ourManager.managedObjectContext performBlock:^{
        [ourManager deleteObjectsOfType:[EventPersonRelation class] context:nil];
        for (NSDictionary *eventDict in events) {
            [EventPersonRelation relationFromJSON:eventDict context:ourManager.managedObjectContext];
        }
        [ourManager save];
        [self syncRelatedEvents:ourManager.managedObjectContext];
    }];
    if (self.completion != NULL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completion();
        });
    }
}

-(void)syncRelatedEvents:(NSManagedObjectContext *)context {
    
    NSArray *figures = [Figure allObjectsInContext:context];
    
    if ([figures count] > 0) {
        
        for (Figure *theFigure in figures) {
            LegacyAppRequest *request = [LegacyAppRequest requestToGetAllEventsForFigure:theFigure];
            
            
            [connection get:request withCompletionBlock:^(LegacyAppRequest *request, NSArray *resultArray, NSError *error) {
                NSManagedObjectContext *ctx = [PersistenceManager managedObjectContext];
                [ctx performBlockAndWait:^{
                    for (NSDictionary *relatedEvent in resultArray) {
                        Event *e = [Event eventFromJSON:relatedEvent context:ctx];
                        
                    }
                    [ctx save];
                }];
            }];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:KeyForLastDateSynced];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
