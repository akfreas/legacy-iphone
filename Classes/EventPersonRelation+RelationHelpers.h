#import "EventPersonRelation.h"

@interface EventPersonRelation (RelationHelpers)

+(void)relationFromJSON:(NSDictionary *)JSONDict context:(NSManagedObjectContext *)context;

@end
