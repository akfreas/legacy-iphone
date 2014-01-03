#import "EventPersonRelation.h"

@interface EventPersonRelation (RelationHelpers)

+(EventPersonRelation *)relationFromJSON:(NSDictionary *)JSONDict context:(NSManagedObjectContext *)context;

@end
