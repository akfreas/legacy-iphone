#import "Event.h"

static NSString *KeyForName = @"name";
static NSString *KeyForDescription = @"description";
static NSString *KeyForAgeYears = @"age_years";
static NSString *KeyForAgeMonths = @"age_months";
static NSString *KeyForAgeDays = @"age_days";
static NSString *KeyForFields = @"fields";

@implementation Event

@synthesize name;
@synthesize description;
@synthesize age_years;
@synthesize age_months;
@synthesize age_days;

-(id)initWithJsonDictionary:(NSDictionary *)jsonDict {
    self = [super init];
    
    if (self) {
        
        NSDictionary *dataDict = [jsonDict objectForKey:KeyForFields];
        
        description = [dataDict objectForKey:KeyForDescription];
        name = [dataDict objectForKey:KeyForName];
        age_years = [dataDict objectForKey:KeyForAgeYears];
        age_months = [dataDict objectForKey:KeyForAgeMonths];
        age_days = [dataDict objectForKey:KeyForAgeDays];
    }
    return self;
}

@end
