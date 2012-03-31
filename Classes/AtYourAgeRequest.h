@interface AtYourAgeRequest : NSObject

+(AtYourAgeRequest *)requestToGetEventWithBirthday:(NSDate *)birthday;

@property (strong, nonatomic) NSURLRequest *urlRequest;
@property (strong, nonatomic) Class classToParse;

@end
