@interface Event : NSObject

@property (nonatomic) NSString *figureName;
@property (nonatomic) NSString *eventDescription;
@property (nonatomic) NSString *ageYears;
@property (nonatomic) NSString *ageMonths;
@property (nonatomic) NSString *ageDays;
@property (nonatomic) NSString *pronoun;
@property (nonatomic) NSURL *figureProfilePicUrl;

-(id)initWithJsonDictionary:(NSDictionary *)theDictionary;

@end
