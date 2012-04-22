@interface Utility_UserInfo : NSObject

+(void)setOrUpdateUserBirthday:(NSDate *)birthday name:(NSString *)name;
+(NSDate *)getBirthdayForName:(NSString *)name;

@end
