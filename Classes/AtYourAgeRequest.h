@class Person;
@interface AtYourAgeRequest : NSObject

+(AtYourAgeRequest *)requestToGetEventForPerson:(Person *)person;
+(AtYourAgeRequest *)requestToGetStoryForPerson:(Person *)person;

@property (strong, nonatomic) NSMutableURLRequest *urlRequest;
@property (strong, nonatomic) Class classToParse;

@end
