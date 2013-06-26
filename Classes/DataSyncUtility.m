#import "DataSyncUtility.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
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
    
    
    [accessor clearEventsAndFiguresAndSave];
    AtYourAgeRequest *request;
    completion = completionBlock;
    Person *primaryPerson = [accessor primaryPerson];

    request = [AtYourAgeRequest requestToGetStoriesForPerson:primaryPerson];
    
    AtYourAgeConnection *connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, NSArray *result, NSError *error) {
        [self parseArrayOfEvents:result];        
    }];
    
}

-(void)syncFacebookFriends:(void(^)())completionBlock {
    
    NSArray *persons = [accessor addedPeople];
    Person *primaryPerson = [accessor primaryPerson];
    AtYourAgeRequest *request = [AtYourAgeRequest requestToSaveFacebookUsers:persons forPerson:primaryPerson];
    
    AtYourAgeConnection *connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, id result, NSError *error) {
        NSLog(@"Person sync result: %@", result);
        completionBlock();
    }];
}

-(void)parseArrayOfEvents:(NSArray *)events {
    
    for (NSDictionary *eventDict in events) {
        [accessor addEventAndFigureWithJson:eventDict];
    }

    [accessor save];
    dispatch_async(dispatch_get_main_queue(), ^{
        completion();
    });
}

@end
