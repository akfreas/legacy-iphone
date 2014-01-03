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
    Event *newEvent = [Event newInContext:context];
    newEvent.ageDays = JSONDict[kAgeDays];
    newEvent.ageMonths = JSONDict[kAgeMonths];
    newEvent.ageYears = JSONDict[kAgeYears];
    newEvent.eventDescription = JSONDict[kEventDescription];
    newEvent.eventId = JSONDict[kEventID];
    
    Figure *figure = [Figure figureFromJSON:JSONDict[kFigure] inContext:context];
    newEvent.figure = figure;
    return newEvent;
}

@end