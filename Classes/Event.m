#import "Event.h"

static NSString *KeyForFigureName = @"figure_name";
static NSString *KeyForEventDescription = @"figure_event";
static NSString *KeyForAgeYears = @"age_years";
static NSString *KeyForAgeMonths = @"age_months";
static NSString *KeyForAgeDays = @"age_days";
static NSString *KeyForPronoun = @"figure_pronoun";
static NSString *KeyForFigureProfilePic = @"figure_profile_pic";
static NSString *KeyForEventId = @"event_id";
static NSString *KeyForFigureId = @"figure_id";

@implementation Event

-(id)initWithJsonDictionary:(NSDictionary *)jsonDict {
    self = [super init];
    
    if (self) {
        
        _eventId = jsonDict[KeyForEventId];
        _eventDescription = jsonDict[KeyForEventDescription];
        _figureName = jsonDict[KeyForFigureName];
        _ageYears = jsonDict[KeyForAgeYears];
        _ageMonths = jsonDict[KeyForAgeMonths];
        _ageDays = jsonDict[KeyForAgeDays];
        _figureProfilePicUrl = [NSURL URLWithString:jsonDict[KeyForFigureProfilePic]];
        _figureId = jsonDict[KeyForFigureId];
        _pronoun = jsonDict[KeyForPronoun];
    }
    return self;
}

-(NSString *)description {
    
    return [NSString stringWithFormat:@"%@ %@ (%@d %@m %@y) %@", _eventId, _eventDescription, _ageDays, _ageMonths, _ageYears, _eventDescription];
}

@end
