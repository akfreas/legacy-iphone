#import "Utility_UserInfo.h"

static NSString *KeyForName = @"name";
static NSString *KeyForBirthday = @"birthday";


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
    
    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionaryWithContentsOfURL:[self userInfoUrl]];
    
    if (userInfoDict == nil) {
        userInfoDict = [NSMutableDictionary dictionaryWithCapacity:1]; 
    }
    
    return userInfoDict;
}

+(void)saveUserInfoDict:(NSMutableDictionary *)userInfoDict {
    
    NSURL *userInfoUrl = [self userInfoUrl];
    [userInfoDict writeToURL:userInfoUrl atomically:YES];
}


+(NSString *)nameFromUserDefaults {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults objectForKey:KeyForName];
}

+(NSDate *)birthdayFromUserDefaults {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults objectForKey:KeyForBirthday];
}

+(void)setNameInUserDefaults:(NSString *)name birthday:(NSDate *)birthday {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:name forKey:KeyForName];
    [defaults setObject:birthday forKey:KeyForBirthday];
}

+(NSString *)birthdayStringFromUserDefaults {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"mm/dd/YYYY"];
    
    NSDate *birthday = [self birthdayFromUserDefaults];
    
    return [dateFormatter stringFromDate:birthday];
}



@end
