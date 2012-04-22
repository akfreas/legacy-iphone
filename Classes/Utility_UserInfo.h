@interface Utility_UserInfo : NSObject

+(void)setOrUpdateUserBirthday:(NSDate *)birthday name:(NSString *)name;
+(NSDate *)getBirthdayForName:(NSString *)name;
+(NSArray *)arrayOfUserInfo;
+(NSString *)birthdayStringFromUserDefaults;
+(NSDate *)birthdayFromUserDefaults;
+(NSString *)nameFromUserDefaults;
+(void)setNameInUserDefaults:(NSString *)name birthday:(NSDate *)birthday;


@end
