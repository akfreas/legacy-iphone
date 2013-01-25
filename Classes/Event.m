#import "Event.h"

static NSString *KeyForName = @"name";
static NSString *KeyForDescription = @"description";
static NSString *KeyForAgeYears = @"age_years";
static NSString *KeyForAgeMonths = @"age_months";
static NSString *KeyForAgeDays = @"age_days";
static NSString *KeyForFields = @"fields";
static NSString *KeyForMale = @"male";
static NSString *KeyForHtml = @"story_html";

@implementation Event

@synthesize name;
@synthesize eventDescription;
@synthesize age_years;
@synthesize age_months;
@synthesize age_days;
@synthesize male;
@synthesize storyHtml;

-(id)initWithJsonDictionary:(NSDictionary *)jsonDict {
    self = [super init];
    
    if (self) {
        
        
        eventDescription = [NSString stringWithFormat:@"%@", [jsonDict objectForKey:KeyForDescription]];
        name = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:KeyForName]];
        age_years = [NSString stringWithFormat:@"%@", [jsonDict objectForKey:KeyForAgeYears]];
        age_months = [NSString stringWithFormat:@"%@", [jsonDict objectForKey:KeyForAgeMonths]];
        age_days = [NSString stringWithFormat:@"%@", [jsonDict objectForKey:KeyForAgeDays]];
        storyHtml = [jsonDict objectForKey:KeyForHtml];
        male = [[jsonDict objectForKey:KeyForMale] boolValue];
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ HTML: %@", eventDescription, storyHtml];
}

@end
