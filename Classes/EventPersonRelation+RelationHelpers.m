#import "EventPersonRelation+RelationHelpers.h"
#import "Figure.h"
#import "Person.h"
#import "Event.h"

@implementation EventPersonRelation (RelationHelpers)

#define kPerson @"person"
#define kErrorKey @"error"

+(void)relationFromJSON:(NSDictionary *)JSONDict context:(NSManagedObjectContext *)context {
    
    Event *event;
    
    if (JSONDict[kErrorKey] == nil) {
        event = [Event eventFromJSON:JSONDict context:context];
    }
    
    NSDictionary *personJSONDict = JSONDict[kPerson];
    Person *person;
    EventPersonRelation *relation = [EventPersonRelation MR_createInContext:context];
    if (personJSONDict != nil) {
        person = [Person personWithJSON:personJSONDict context:context];
        relation.person = person;
    }
    
    relation.event = event;
}

@end
