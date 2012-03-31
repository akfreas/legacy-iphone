@interface Event : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;

-(id)initWithJsonDictionary:(NSDictionary *)theDictionary;

@end
