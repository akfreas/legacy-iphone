#import "Event.h"

@interface Event (EventHelper)

+(Event *)eventFromJSON:(NSDictionary *)JSONDict context:(NSManagedObjectContext *)context;
+(NSArray *)eventsForFigure:(Figure *)figure inContext:(NSManagedObjectContext *)context;

@end
