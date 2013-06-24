#import "DataSyncUtility.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "ObjectArchiveAccessor.h"
#import "Figure.h"
#import "Event.h"

@implementation DataSyncUtility {
    
    NSOperationQueue *queue;
    ObjectArchiveAccessor *accessor;
}

-(id)init {
    self = [super init];
    
    if (self) {
        accessor = [[ObjectArchiveAccessor alloc] init];
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)sync:(void (^)())completion {
    
    
    [accessor clearEventsAndFiguresAndSave];
    AtYourAgeRequest *request;
    Person *primaryPerson = [accessor primaryPerson];

    request = [AtYourAgeRequest requestToGetStoriesForPerson:primaryPerson];
    
    AtYourAgeConnection *connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, NSArray *result, NSError *error) {
        [self parseArrayOfEvents:result];
        completion();
        
    }];
    
}

-(void)parseArrayOfEvents:(NSArray *)events {
    
    for (NSDictionary *eventDict in events) {
        [accessor addEventAndFigureWithJson:eventDict];
    }
    [accessor save];
}

@end
