@class Person;
@class Figure;
@interface LegacyAppRequest : NSObject

+(LegacyAppRequest *)requestToGetStoriesForPerson:(Person *)person;
+(LegacyAppRequest *)requestToSaveFacebookUsers:(NSArray *)users forPerson:(Person *)person;
+(LegacyAppRequest *)requestToGetAllEventsForFigure:(Figure *)figure;
+(LegacyAppRequest *)requestToPostDeviceInformation:(NSDictionary *)deviceInfo person:(Person *)person;
+(LegacyAppRequest *)requestToDeletePerson:(Person *)person;
@property (strong, nonatomic) NSMutableURLRequest *urlRequest;
@property (strong, nonatomic) Class classToParse;

@end
