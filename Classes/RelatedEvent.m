#import "RelatedEvent.h"

static NSString *KeyForAgeYears = @"age_years";
static NSString *KeyForAgeMonths = @"age_months";
static NSString *KeyForAgeDays = @"age_days";
static NSString *KeyForEventDescription = @"description";

@implementation RelatedEvent

-(id)initWithJsonDictionary:(NSDictionary *)jsonDict {

    self = [super init];
    
    if (self) {
        
        _ageDays = [jsonDict objectForKey:KeyForAgeDays];
        _ageMonths = [jsonDict objectForKey:KeyForAgeMonths];
        _ageYears = [jsonDict objectForKey:KeyForAgeYears];
        _eventDescription = [jsonDict objectForKey:KeyForEventDescription];
    }
    
    return self;
}

@end
