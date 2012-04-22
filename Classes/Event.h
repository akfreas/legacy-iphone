@interface Event : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *eventDescription;
@property (strong, nonatomic) NSString *age_years;
@property (strong, nonatomic) NSString *age_months;
@property (strong, nonatomic) NSString *age_days;

-(id)initWithJsonDictionary:(NSDictionary *)theDictionary;

@end
