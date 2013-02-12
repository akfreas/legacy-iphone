@class User;
@interface YardstickRequest : NSObject

+(YardstickRequest *)requestToGetEventForPerson:(User *)user;
+(YardstickRequest *)requestToGetStoryForPerson:(User *)user;

@property (strong, nonatomic) NSURLRequest *urlRequest;
@property (strong, nonatomic) Class classToParse;

@end
