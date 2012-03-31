#import "Event.h"

static NSString *KeyForName = @"name";
static NSString *KeyForDescription = @"description";

@implementation Event

@synthesize name;
@synthesize description;

-(id)initWithJsonDictionary:(NSDictionary *)jsonDict {
    self = [super init];
    
    if (self) {
        description = [jsonDict objectForKey:KeyForDescription];
        name = [jsonDict objectForKey:KeyForName];
    }
    return self;
}

@end
