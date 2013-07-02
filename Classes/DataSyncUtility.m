#import "DataSyncUtility.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "ObjectArchiveAccessor.h"
#import "Figure.h"
#import "Event.h"
#import "Person.h"

@implementation DataSyncUtility {
    
    NSOperationQueue *queue;
    ObjectArchiveAccessor *accessor;
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
        accessor = [[ObjectArchiveAccessor alloc] init];
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)sync:(void (^)())completionBlock {
    
    
    LegacyAppRequest *request;
    completion = completionBlock;
    Person *primaryPerson = [accessor primaryPerson];

    request = [LegacyAppRequest requestToGetStoriesForPerson:primaryPerson];
    
    LegacyAppConnection *connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
    
    [connection getWithCompletionBlock:^(LegacyAppRequest *request, NSArray *result, NSError *error) {
        [accessor clearEventsAndFiguresAndSave];
        [self parseArrayOfEventsForTable:result];
    }];
    
}

-(void)syncFacebookFriends:(void(^)())completionBlock {
    
    NSArray *persons = [accessor addedPeople];
    Person *primaryPerson = [accessor primaryPerson];
    LegacyAppRequest *request = [LegacyAppRequest requestToSaveFacebookUsers:persons forPerson:primaryPerson];
    
    LegacyAppConnection *connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
    [connection getWithCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
        NSLog(@"Person sync result: %@", result);
        if (completionBlock != NULL) {
            completionBlock();
        }
    }];
}

-(void)parseArrayOfEventsForTable:(NSArray *)events {
    
    for (NSDictionary *eventDict in events) {
        [accessor addEventAndFigureRelationWithJson:eventDict];
    }

    [accessor save];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForRowDataUpdated object:nil];
        completion();
    });
    [self syncRelatedEvents];
}

-(void)syncRelatedEvents {
    
    NSArray *figures = [accessor allFigures];
    NSLog(@"figures: %@", figures);
//    for (Figure *figure in figures) {
    
    if ([figures count] > 0) {
        
        for (Figure *theFigure in figures) {
            LegacyAppRequest *request = [LegacyAppRequest requestToGetAllEventsForFigure:theFigure];
            
            LegacyAppConnection *connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
            
            [connection getWithCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
                ObjectArchiveAccessor *ourAccessor = [[ObjectArchiveAccessor alloc] init];
                NSLog(@"event result: %@", result);
                NSArray *resultArray = (NSArray *)result;
                for (NSDictionary *relatedEvent in resultArray) {
                    [ourAccessor addEventAndFigureWithJson:relatedEvent];
                }
            }];
        }
    }
}

@end
