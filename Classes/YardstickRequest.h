@class Person;
@interface YardstickRequest : NSObject

+(YardstickRequest *)requestToGetEventForPerson:(Person *)person;
+(YardstickRequest *)requestToGetStoryForPerson:(Person *)person;

@property (strong, nonatomic) NSMutableURLRequest *urlRequest;
@property (strong, nonatomic) Class classToParse;

@end
