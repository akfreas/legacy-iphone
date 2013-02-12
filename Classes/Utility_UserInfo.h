@interface Utility_PersonInfo : NSObject

+(void)setOrUpdatePersonBirthday:(NSDate *)birthday name:(NSString *)name;
+(NSDate *)birthdayForName:(NSString *)name;
+(NSArray *)arrayOfPersonInfo;
+(NSString *)birthdayStringForCurrentName;
+(NSDate *)birthdayForCurrentName;
+(NSString *)currentName;
+(void)setCurrentName:(NSString *)name;


@end
