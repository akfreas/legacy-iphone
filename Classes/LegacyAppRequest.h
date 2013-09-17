@class Person;
@class Figure;
@interface LegacyAppRequest : NSObject

+(LegacyAppRequest *)requestToUpdateBirthday:(NSDate *)birthday forPerson:(Person *)person;
+(LegacyAppRequest *)requestToGetStoriesForPerson:(Person *)person;
+(LegacyAppRequest *)requestToSaveFacebookUsers:(NSArray *)users forPerson:(Person *)person;
+(LegacyAppRequest *)requestToGetAllEventsForFigure:(Figure *)figure;
+(LegacyAppRequest *)requestToPostDeviceInformation:(NSDictionary *)deviceInfo person:(Person *)person;
@property (strong, nonatomic) NSMutableURLRequest *urlRequest;
@property (strong, nonatomic) Class classToParse;

@end
