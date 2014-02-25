@class Person;
@class Figure;
@interface LegacyAppRequest : NSObject

+(LegacyAppRequest *)requestToGetAllStoriesForPrimaryPerson:(Person *)person;
+(LegacyAppRequest *)requestToSaveFacebookUsers:(NSArray *)users forPerson:(Person *)person;
+(LegacyAppRequest *)requestToGetAllEventsForFigure:(Figure *)figure;
+(LegacyAppRequest *)requestToGetEventForPerson:(Person *)person;
+(LegacyAppRequest *)requestToPostDeviceInformation:(NSDictionary *)deviceInfo person:(Person *)person;
+(LegacyAppRequest *)requestToDeletePerson:(Person *)person;
+(LegacyAppRequest *)requestToAddPerson:(Person *)person;
+(LegacyAppRequest *)requestToVerifyPasscode:(NSString *)passcode;
+(LegacyAppRequest *)requestToGetConfiguration;
@property (strong, nonatomic) NSMutableURLRequest *urlRequest;
@property (strong, nonatomic) Class classToParse;

@end
