#import "Event.h"

static NSString *KeyForName = @"name";
static NSString *KeyForDescription = @"description";
static NSString *KeyForAgeYears = @"age_years";
static NSString *KeyForAgeMonths = @"age_months";
static NSString *KeyForAgeDays = @"age_days";
static NSString *KeyForFields = @"fields";
static NSString *KeyForMale = @"male";

@implementation Event

@synthesize name;
@synthesize eventDescription;
@synthesize age_years;
@synthesize age_months;
@synthesize age_days;
@synthesize male;

-(id)initWithJsonDictionary:(NSDictionary *)jsonDict {
    self = [super init];
    
    if (self) {
        
        NSDictionary *dataDict = [jsonDict objectForKey:KeyForFields];
        
        eventDescription = [NSString stringWithFormat:@"%@", [dataDict objectForKey:KeyForDescription]];
        name = [NSString stringWithFormat:@"%@",[dataDict objectForKey:KeyForName]];
        age_years = [NSString stringWithFormat:@"%@", [dataDict objectForKey:KeyForAgeYears]];
        age_months = [NSString stringWithFormat:@"%@", [dataDict objectForKey:KeyForAgeMonths]];
        age_days = [NSString stringWithFormat:@"%@", [dataDict objectForKey:KeyForAgeDays]];
        male = [[dataDict objectForKey:KeyForMale] boolValue];
        
        
    }
    return self;
}

@end
