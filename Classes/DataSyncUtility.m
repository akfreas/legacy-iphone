#import "DataSyncUtility.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "Figure.h"
#import "Event.h"
#import "Person.h"

@implementation DataSyncUtility {
    
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


-(void)sync:(void (^)())completionBlock {
    LegacyAppRequest *request;
    completion = completionBlock;
    Person *primaryPerson = [Person primaryPersonInContext:nil];
    
    request = [LegacyAppRequest requestToGetAllStoriesForPrimaryPerson:primaryPerson];
    
    [LegacyAppConnection get:request withCompletionBlock:^(LegacyAppRequest *request, NSArray *result, NSError *error) {
        [self parseArrayOfEventsForTable:result];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:KeyForLastDateSynced];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
}

-(void)syncFacebookFriends:(void(^)())completionBlock {
    
    NSArray *persons = [Person MR_findAllInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    Person *primaryPerson = [Person MR_findFirstByAttribute:@"isPrimary" withValue:[NSNumber numberWithBool:YES]];
    LegacyAppRequest *request = [LegacyAppRequest requestToSaveFacebookUsers:persons forPerson:primaryPerson];
    
    [LegacyAppConnection get:request withCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
        
        if (completionBlock != NULL) {
            completionBlock();
        }
    }];
}

-(void)parseArrayOfEventsForTable:(NSArray *)events completion:(void (^)())completionBlock {
    completion = completionBlock;
    [self parseArrayOfEventsForTable:events];
}

-(void)parseArrayOfEventsForTable:(NSArray *)events {
    
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    [ctx performBlock:^{
        [EventPersonRelation MR_deleteAllMatchingPredicate:nil inContext:ctx];
        for (NSDictionary *eventDict in events) {
            [EventPersonRelation relationFromJSON:eventDict context:ctx];
        }
        [ctx MR_saveOnlySelfAndWait];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion != NULL) {
                completion();
            }
        });
    }];
    
}

-(void)syncRelatedEventsInContext:(NSManagedObjectContext *)ctx {
    
    NSArray *figures = [Figure MR_findAllInContext:ctx];
    if ([figures count] > 0) {
        
        for (Figure *theFigure in figures) {
            [DataSyncUtility syncRelatedEventForFigure:theFigure];
        }
    }
}

+(void)syncRelatedEventForFigure:(Figure *)figure {
    LegacyAppRequest *request = [LegacyAppRequest requestToGetAllEventsForFigure:figure];
    NSManagedObjectContext *ctx = [NSManagedObjectContext MR_context];
    NSManagedObjectID *figureID = figure.objectID;
    [LegacyAppConnection get:request withCompletionBlock:^(LegacyAppRequest *request, id result, NSError *error) {
        NSArray *resultArray = (NSArray *)result;
        [ctx performBlock:^{
            
            for (NSDictionary *relatedEvent in resultArray) {
                [Event eventFromJSON:relatedEvent context:ctx];
            }
            [ctx save];
            Figure *ourFigure = [Figure objectWithObjectID:figureID inContext:ctx];
            if ([ourFigure.events count] == [ourFigure.associatedEvents integerValue]) {
                ourFigure.eventsSynced = [NSNumber numberWithBool:YES];
            } else {
                ourFigure.eventsSynced = [NSNumber numberWithBool:NO];
            }
            [ctx MR_saveWithOptions:MRSaveParentContexts completion:^(BOOL success, NSError *error) {
                NSAssert(success == YES || error == nil, @"Saving parent contexts failed.");
                
            }];
        }];
    }];
}

@end
