@interface Utility_AppSettings : NSObject

+(UIFont *)applicationFontWithSize:(CGFloat)fontSize;
+(UIFont *)applicationFontLarge;
+(UIFont *)applicationFontMedium;
+(UIFont *)applicationFontSmall;

+(NSDateFormatter *)dateFormatterForDisplay;
+(NSDateFormatter *)dateFormatterForRequest;
+(NSDateFormatter *)dateFormatterForPartialBirthday;
+(CGRect)frameForKeyWindow;

@end
