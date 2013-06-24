@class Person;
@interface AtYourAgeRequest : NSObject

+(AtYourAgeRequest *)requestToGetStoryForPerson:(Person *)person;
+(AtYourAgeRequest *)requestToUpdateBirthday:(NSDate *)birthday forPerson:(Person *)person;
+(AtYourAgeRequest *)requestToGetRelatedEventsForEvent:(NSString *)event requester:(Person *)person;
+(AtYourAgeRequest *)requestToGetFigureWithId:(NSString *)theId requester:(Person *)requester;
+(AtYourAgeRequest *)requestToGetRandomStories;
+(AtYourAgeRequest *)requestToGetStoriesForPerson:(Person *)person;
+(AtYourAgeRequest *)requestToSaveFacebookUsers:(NSArray *)users forPerson:(Person *)person;

@property (strong, nonatomic) NSMutableURLRequest *urlRequest;
@property (strong, nonatomic) Class classToParse;

@end
