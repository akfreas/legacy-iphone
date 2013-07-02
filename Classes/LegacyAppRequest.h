@class Person;
@class Figure;
@interface LegacyAppRequest : NSObject

+(LegacyAppRequest *)requestToGetStoryForPerson:(Person *)person;
+(LegacyAppRequest *)requestToUpdateBirthday:(NSDate *)birthday forPerson:(Person *)person;
+(LegacyAppRequest *)requestToGetRelatedEventsForEvent:(NSString *)event requester:(Person *)person;
+(LegacyAppRequest *)requestToGetFigureWithId:(NSString *)theId requester:(Person *)requester;
+(LegacyAppRequest *)requestToGetRandomStories;
+(LegacyAppRequest *)requestToGetStoriesForPerson:(Person *)person;
+(LegacyAppRequest *)requestToSaveFacebookUsers:(NSArray *)users forPerson:(Person *)person;
+(LegacyAppRequest *)requestToGetAllEventsForFigure:(Figure *)figure;
@property (strong, nonatomic) NSMutableURLRequest *urlRequest;
@property (strong, nonatomic) Class classToParse;

@end
