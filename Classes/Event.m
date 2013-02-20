#import "Event.h"

static NSString *KeyForFigureName = @"figure_name";
static NSString *KeyForEventDescription = @"figure_event";
static NSString *KeyForAgeYears = @"age_years";
static NSString *KeyForAgeMonths = @"age_months";
static NSString *KeyForAgeDays = @"age_days";
static NSString *KeyForPronoun = @"figure_pronoun";
static NSString *KeyForFigureProfilePic = @"figure_profile_pic";

@implementation Event

-(id)initWithJsonDictionary:(NSDictionary *)jsonDict {
    self = [super init];
    
    if (self) {
        
        
        _eventDescription = [NSString stringWithFormat:@"%@", [jsonDict objectForKey:KeyForEventDescription]];
        _figureName = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:KeyForFigureName]];
        _ageYears = [NSString stringWithFormat:@"%@", [jsonDict objectForKey:KeyForAgeYears]];
        _ageMonths = [NSString stringWithFormat:@"%@", [jsonDict objectForKey:KeyForAgeMonths]];
        _ageDays = [NSString stringWithFormat:@"%@", [jsonDict objectForKey:KeyForAgeDays]];
        _figureProfilePicUrl = [NSURL URLWithString:[jsonDict objectForKey:KeyForFigureProfilePic]];
        _pronoun = [jsonDict objectForKey:KeyForPronoun];
    }
    return self;
}

//-(NSString *)description {
//    
//    return [NSString stringWithFormat:@"%@ (%@d %@m %@y) %@ HTML: %@",name, age_days, age_months, age_years, eventDescription, storyHtml];
//}

@end
