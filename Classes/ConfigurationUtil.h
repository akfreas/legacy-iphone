@interface ConfigurationUtil : NSObject

+(BOOL)shouldUseWikipediaForSharing;
+(BOOL)appHasBeenUpgraded;
+(void)saveCurrentAppVersion;
+(NSURL *)shareURL;
+(void)saveConfigFromJSON:(NSDictionary *)json;

@end
