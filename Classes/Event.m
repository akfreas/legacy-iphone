#import "Event.h"

static NSString *KeyForName = @"name";
static NSString *KeyForDescription = @"description";
static NSString *KeyForFields = @"fields";

@implementation Event

@synthesize name;
@synthesize description;

-(id)initWithJsonDictionary:(NSDictionary *)jsonDict {
    self = [super init];
    
    if (self) {
        description = [[jsonDict objectForKey:KeyForFields] objectForKey:KeyForDescription];
        name = [[jsonDict objectForKey:KeyForFields] objectForKey:KeyForName];
    }
    return self;
}

@end
