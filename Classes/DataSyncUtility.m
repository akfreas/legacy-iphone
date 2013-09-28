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
        accessor = [ObjectArchiveAccessor sharedInstance];
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)sync:(void (^)())completionBlock {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    LegacyAppRequest *request;
    completion = completionBlock;
    Person *primaryPerson = [accessor primaryPerson];

    request = [LegacyAppRequest requestToGetStoriesForPerson:primaryPerson];
    
    connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
    
    [connection getWithCompletionBlock:^(LegacyAppRequest *request, NSArray *result, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ObjectArchiveAccessor *ourAccessor = [ObjectArchiveAccessor sharedInstance];
            [ourAccessor clearEventsAndFiguresAndSave];
            [self parseArrayOfEventsForTable:result];
        });
    }];
    
}

-(void)syncFacebookFriends:(void(^)())completionBlock {
    
    NSArray *persons = [accessor addedPeople];
    Person *primaryPerson = [accessor primaryPerson];
    LegacyAppRequest *request = [LegacyAppRequest requestToSaveFacebookUsers:persons forPerson:primaryPerson];
    
    connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
    
    
    [connection getWithCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
        
        
        if (completionBlock != NULL) {
            completionBlock();
        }
    }];
}

-(void)parseArrayOfEventsForTable:(NSArray *)events {
    
    for (NSDictionary *eventDict in events) {
        [accessor addEventAndFigureRelationWithJson:eventDict];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForRowDataUpdated object:nil];
        if (completion != NULL) {
            completion();
        }
    });
    [self syncRelatedEvents];
}

-(void)syncRelatedEvents {
    
    NSArray *figures = [accessor allFigures];
    
    if ([figures count] > 0) {
        
        for (Figure *theFigure in figures) {
            LegacyAppRequest *request = [LegacyAppRequest requestToGetAllEventsForFigure:theFigure];
            
            connection = [[LegacyAppConnection alloc] initWithLegacyRequest:request];
            
            [connection getWithCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
                ObjectArchiveAccessor *ourAccessor = [ObjectArchiveAccessor sharedInstance];
                NSArray *resultArray = (NSArray *)result;
                for (NSDictionary *relatedEvent in resultArray) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ourAccessor addEventAndFigureWithJson:relatedEvent];
                    });
                }
            }];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:KeyForLastDateSynced];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
