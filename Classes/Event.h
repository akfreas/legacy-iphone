@interface Event : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *eventDescription;
@property (strong, nonatomic) NSString *age_years;
@property (strong, nonatomic) NSString *age_months;
@property (strong, nonatomic) NSString *age_days;

@property (atomic) BOOL male;

-(id)initWithJsonDictionary:(NSDictionary *)theDictionary;

@end
