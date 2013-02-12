@class User;
@interface YardstickRequest : NSObject

+(YardstickRequest *)requestToGetEventForUser:(User *)user;
+(YardstickRequest *)requestToGetStoryForUser:(User *)user;

@property (strong, nonatomic) NSURLRequest *urlRequest;
@property (strong, nonatomic) Class classToParse;

@end
