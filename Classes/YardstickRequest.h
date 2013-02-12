@class Person;
@interface YardstickRequest : NSObject

+(YardstickRequest *)requestToGetEventForPerson:(Person *)person;
+(YardstickRequest *)requestToGetStoryForPerson:(Person *)person;

@property (strong, nonatomic) NSURLRequest *urlRequest;
@property (strong, nonatomic) Class classToParse;

@end
