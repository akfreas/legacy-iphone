#import "EventPersonRelation+RelationHelpers.h"
#import "Figure.h"
#import "Person.h"
#import "Event.h"

@implementation EventPersonRelation (RelationHelpers)

#define kPerson @"person"

+(void)relationFromJSON:(NSDictionary *)JSONDict context:(NSManagedObjectContext *)context {
    Event *event = [Event eventFromJSON:JSONDict context:context];
    NSDictionary *personJSONDict = JSONDict[kPerson];
    Person *person;
    if (personJSONDict != nil) {
        person = [Person personWithJSON:personJSONDict context:context];
    }
    
    EventPersonRelation *relation = [EventPersonRelation MR_createInContext:context];
    relation.event = event;
    relation.person = person;
    
    //    return relation;
}

@end
