#import "Utility_UserInfo.h"

static NSString *KeyForName = @"name";
static NSString *KeyForBirthday = @"birthday";
static NSString *KeyForRootInfoDict = @"Names";
static NSString *KeyForCurrentName = @"CurrentName";


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

+(NSDate *)birthdayForName:(NSString *)name {
    
    NSMutableDictionary *userInfoDict = [self userInfoDict];
    
    NSLog(@"USerinfodict: %@:", userInfoDict);
    
    return [userInfoDict objectForKey:name];
}

+(NSArray *)arrayOfUserInfo {
    NSDictionary *userInfoDict = [self userInfoDict];

    NSMutableArray *userInfo = [NSMutableArray arrayWithCapacity:1];
    
    for (NSString *name in [userInfoDict allKeys]) {
        NSDictionary *singleUserInfo = [NSDictionary dictionaryWithObject:[userInfoDict objectForKey:name] forKey:name];
        [userInfo addObject:singleUserInfo];
    }
    
    return userInfo;
}

+(NSMutableDictionary *)userInfoDict {
    
    NSMutableDictionary *userInfoDict = [[NSMutableDictionary dictionaryWithContentsOfURL:[self userInfoUrl]] objectForKey:KeyForRootInfoDict];
    
    if (userInfoDict == nil) {
        userInfoDict = [NSMutableDictionary dictionaryWithCapacity:1]; 
    }
    
    return userInfoDict;
}

+(void)saveUserInfoDict:(NSMutableDictionary *)userInfoDict {
    
    NSURL *userInfoUrl = [self userInfoUrl];
    
    NSMutableDictionary *rootUserInfoDict = [NSMutableDictionary dictionaryWithContentsOfURL:userInfoUrl];
    
    [rootUserInfoDict setObject:userInfoDict forKey:KeyForRootInfoDict];
    NSLog(@"Url: %@", userInfoUrl);
    [rootUserInfoDict writeToURL:userInfoUrl atomically:YES];
}


+(NSString *)currentName {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfURL:[self userInfoUrl]];
    
    NSString *currentName = [dict objectForKey:KeyForCurrentName];
    
    return currentName;
}

+(void)setCurrentName:(NSString *)name {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfURL:[self userInfoUrl]];
    
    if (dict == nil) {
        dict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    [dict setObject:name forKey:KeyForCurrentName];
    
    [dict writeToURL:[self userInfoUrl] atomically:YES];
}

+(NSDate *)birthdayForCurrentName {
        
    NSString *currentName = [self currentName];
    
    return [[self userInfoDict] objectForKey:currentName];
}

+(NSString *)birthdayStringForCurrentName {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"mm/dd/YYYY"];
    
    NSDate *birthday = [self birthdayForCurrentName];
    
    return [dateFormatter stringFromDate:birthday];
}



@end
