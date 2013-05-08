@interface RelatedEvent : NSObject

@property (nonatomic, readonly) NSString *dateString;

@property (nonatomic) NSString *ageDays;
@property (nonatomic) NSString *ageMonths;
@property (nonatomic) NSString *ageYears;
@property (nonatomic) NSString *eventDescription;

-(id)initWithJsonDictionary:(NSDictionary *)jsonDict;
@end
