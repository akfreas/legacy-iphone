#import "ConfigurationUtil.h"
#define ConfigShouldUseWikipediaKey @"use_direct_wikipedia_link"
#define ConfigShareURLRoot @"root_share_url"
#define ConfigCurrentVersionNumber @"current_app_version"
@implementation ConfigurationUtil

+(BOOL)shouldUseWikipediaForSharing {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:ConfigShouldUseWikipediaKey] boolValue];
}

+(BOOL)appHasBeenUpgraded {
    NSNumber *currentVersionNumber = @([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue]);
    NSNumber *previousVersionNumber = [[NSUserDefaults standardUserDefaults] objectForKey:ConfigCurrentVersionNumber];
    [[NSUserDefaults standardUserDefaults] setObject:currentVersionNumber forKey:ConfigCurrentVersionNumber];
    if (previousVersionNumber == nil) {
        return YES;
    }
    
    if ([currentVersionNumber floatValue] > [previousVersionNumber floatValue]) {
        return YES;
    } else {
        return NO;
    }
}

+(NSURL *)shareURL {
    NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:ConfigShareURLRoot]];
    return url;
}

+(void)saveConfigFromJSON:(NSDictionary *)json {
    for (id jsonKey in [json allKeys]) {
        [[NSUserDefaults standardUserDefaults] setObject:json[jsonKey] forKey:jsonKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
