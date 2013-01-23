@interface Event : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *eventDescription;
@property (nonatomic) NSString *age_years;
@property (nonatomic) NSString *age_months;
@property (nonatomic) NSString *age_days;
@property (nonatomic) NSString *storyHtml;

@property (atomic) BOOL male;

-(id)initWithJsonDictionary:(NSDictionary *)theDictionary;

@end
