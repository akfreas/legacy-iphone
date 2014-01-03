#import "Person.h"

@interface Person (PersonHelper)

+(NSArray *)allPersonsInContext:(NSManagedObjectContext *)context includePrimary:(BOOL)includePrimary;
+(Person *)personWithFacebookID:(NSString *)facebookID context:(NSManagedObjectContext *)context;
+(Person *)personWithJSON:(NSDictionary *)JSONDict context:(NSManagedObjectContext *)context;
+(Person *)personWithFacebookGraphUser:(id<FBGraphUser>)graphUser inContext:(NSManagedObjectContext *)context;
@end
