@class User;
@interface AtYourAgeRequest : NSObject

+(AtYourAgeRequest *)requestToGetEventForUser:(User *)user;

@property (strong, nonatomic) NSURLRequest *urlRequest;
@property (strong, nonatomic) Class classToParse;

@end
