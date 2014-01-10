#import "Event+EventHelper.h"
#import "Figure.h"

@implementation Event (EventHelper)

#define kAgeDays @"age_days"
#define kAgeMonths @"age_months"
#define kAgeYears @"age_years"
#define kEventDescription @"event_description"
#define kEventID @"event_id"
#define kFigure @"figure"

+(Event *)eventFromJSON:(NSDictionary *)JSONDict context:(NSManagedObjectContext *)context {
    NSArray *existingEvents = [Event MR_findByAttribute:@"eventId" withValue:JSONDict[kEventID] inContext:context];
    Event *newEvent;
    if ([existingEvents count] > 0) {
        newEvent = [existingEvents firstObject];
        return newEvent;
    } else {
        newEvent = [Event MR_createInContext:context];
    }
    newEvent.ageDays = JSONDict[kAgeDays];
    newEvent.ageMonths = JSONDict[kAgeMonths];
    newEvent.ageYears = JSONDict[kAgeYears];
    newEvent.eventDescription = JSONDict[kEventDescription];
    newEvent.eventId = JSONDict[kEventID];
    
    Figure *figure = [Figure figureFromJSON:JSONDict[kFigure] inContext:context];
    newEvent.figure = figure;
    return newEvent;
}

+(NSArray *)sortDescriptors {
    NSArray *arr = @[[NSSortDescriptor sortDescriptorWithKey:@"ageYears" ascending:YES],
                     [NSSortDescriptor sortDescriptorWithKey:@"ageMonths" ascending:YES],
                     [NSSortDescriptor sortDescriptorWithKey:@"ageDays" ascending:YES]];
    return arr;
}

+(NSArray *)eventsForFigure:(Figure *)figure inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [self baseFetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"figure == %@", figure];
    request.sortDescriptors = [self sortDescriptors];
    NSArray *returnArr = [context executeFetchRequest:request];
    return returnArr;
}

@end
