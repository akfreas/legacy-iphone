#import "Utility_UserInfo.h"

@implementation Utility_UserInfo


+(NSURL *)userInfoUrl {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    url = [url URLByAppendingPathComponent:@"UserInfo.plist"];
    
    return url;
}

+(void)setOrUpdateUserBirthday:(NSDate *)birthday name:(NSString *)name {
    
    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionaryWithContentsOfURL:[Utility_UserInfo userInfoUrl]];
    [userInfoDict setObject:birthday forKey:name];
    
    [Utility_UserInfo saveUserInfoDict:userInfoDict];
}

+(void)saveUserInfoDict:(NSMutableDictionary *)userInfoDict {
    
    NSURL *userInfoUrl = [Utility_UserInfo userInfoUrl];
    [userInfoDict writeToURL:userInfoUrl atomically:YES];
}

@end
