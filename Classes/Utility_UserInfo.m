#import "Utility_PersonInfo.h"

static NSString *KeyForName = @"name";
static NSString *KeyForBirthday = @"birthday";
static NSString *KeyForRootInfoDict = @"Names";
static NSString *KeyForCurrentName = @"CurrentName";


@implementation Utility_PersonInfo


+(NSURL *)userInfoUrl {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    url = [url URLByAppendingPathComponent:@"PersonInfo.plist"];
    
    return url;
}

+(void)setOrUpdatePersonBirthday:(NSDate *)birthday name:(NSString *)name {
    
    NSMutableDictionary *userInfoDict = [self userInfoDict];
    
    [userInfoDict setObject:birthday forKey:name];
    
    [Utility_PersonInfo savePersonInfoDict:userInfoDict];
}

+(NSDate *)birthdayForName:(NSString *)name {
    
    NSMutableDictionary *userInfoDict = [self userInfoDict];
    
    NSLog(@"USerinfodict: %@:", userInfoDict);
    
    return [userInfoDict objectForKey:name];
}

+(NSArray *)arrayOfPersonInfo {
    NSDictionary *userInfoDict = [self userInfoDict];

    NSMutableArray *userInfo = [NSMutableArray arrayWithCapacity:1];
    
    for (NSString *name in [userInfoDict allKeys]) {
        NSDictionary *singlePersonInfo = [NSDictionary dictionaryWithObject:[userInfoDict objectForKey:name] forKey:name];
        [userInfo addObject:singlePersonInfo];
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

+(void)savePersonInfoDict:(NSMutableDictionary *)userInfoDict {
    
    NSURL *userInfoUrl = [self userInfoUrl];
    
    NSMutableDictionary *rootPersonInfoDict = [NSMutableDictionary dictionaryWithContentsOfURL:userInfoUrl];
    
    [rootPersonInfoDict setObject:userInfoDict forKey:KeyForRootInfoDict];
    
    
    NSLog(@"Url: %@", userInfoUrl);
    [rootPersonInfoDict writeToURL:userInfoUrl atomically:YES];
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
