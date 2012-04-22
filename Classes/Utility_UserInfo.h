@interface Utility_UserInfo : NSObject

+(void)setOrUpdateUserBirthday:(NSDate *)birthday name:(NSString *)name;
+(NSDate *)birthdayForName:(NSString *)name;
+(NSArray *)arrayOfUserInfo;
+(NSString *)birthdayStringForCurrentName;
+(NSDate *)birthdayForCurrentName;
+(NSString *)currentName;
+(void)setCurrentName:(NSString *)name;


@end
