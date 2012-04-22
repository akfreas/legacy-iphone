#import "Utility_UserInfo.h"

@implementation Utility_UserInfo


+(NSURL *)userInfoUrl {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    url = [url URLByAppendingPathComponent:@"UserInfo.plist"];
    
    return url;
}

+(void)setOrUpdateUserBirthday:(NSDate *)birthday name:(NSString *)name {
    
    NSMutableDictionary *userInfoDict = [self userInfoDict];
    
    [userInfoDict setObject:birthday forKey:name];
    
    [Utility_UserInfo saveUserInfoDict:userInfoDict];
}

+(NSDate *)getBirthdayForName:(NSString *)name {
    
    NSMutableDictionary *userInfoDict = [self userInfoDict];
    
    return [userInfoDict objectForKey:name];
}

+(NSMutableDictionary *)userInfoDict {
    return [NSMutableDictionary dictionaryWithContentsOfURL:[self userInfoUrl]];
}

+(void)saveUserInfoDict:(NSMutableDictionary *)userInfoDict {
    
    NSURL *userInfoUrl = [self userInfoUrl];
    [userInfoDict writeToURL:userInfoUrl atomically:YES];
}

@end
