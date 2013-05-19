@interface RelatedEvent : NSObject

@property (nonatomic, readonly) NSString *dateString;

@property (nonatomic) NSString *ageDays;
@property (nonatomic) NSString *ageMonths;
@property (nonatomic) NSString *ageYears;
@property (nonatomic) NSString *eventDescription;
@property (assign) BOOL isSelf;

-(id)initWithJsonDictionary:(NSDictionary *)jsonDict;
@end
