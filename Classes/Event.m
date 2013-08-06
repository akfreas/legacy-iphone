//
//  Event.m
//  Legacy
//
//  Created by Alexander Freas on 6/19/13.
//
//

#import "Event.h"
#import "Figure.h"
#import "Person.h"


@implementation Event

@dynamic eventDescription;
@dynamic ageYears;
@dynamic ageMonths;
@dynamic ageDays;
@dynamic eventId;
@dynamic figure;

static NSString *KeyForEventDescription = @"figure_event";
static NSString *KeyForAgeYears = @"age_years";
static NSString *KeyForAgeMonths = @"age_months";
static NSString *KeyForAgeDays = @"age_days";
static NSString *KeyForEventId = @"event_id";

-(id)initWithJsonDictionary:(NSDictionary *)jsonDict {
    self = [super init];
    
    if (self) {
        
        self.eventId = jsonDict[KeyForEventId];
        self.eventDescription = jsonDict[KeyForEventDescription];
        self.ageYears = jsonDict[KeyForAgeYears];
        self.ageMonths = jsonDict[KeyForAgeMonths];
        self.ageDays = jsonDict[KeyForAgeDays];
    }
    return self;
}

-(NSString *)description {
    
    return [NSString stringWithFormat:@"%@ %@ (%@d %@m %@y) %@", self.eventId, self.eventDescription, self.ageDays, self.ageMonths, self.ageYears, self.eventDescription];
}


@end
