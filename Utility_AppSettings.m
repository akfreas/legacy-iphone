#import "Utility_AppSettings.h"

@implementation Utility_AppSettings

+(UIFont *)applicationFontWithSize:(CGFloat)fontSize {
    
    UIFont *appFont = [UIFont fontWithName:@"AmericanTypewriter" size:fontSize];
    
    return appFont;
}

+(UIFont *)applicationFontLarge {
    return [self applicationFontWithSize:18];
}

+(UIFont *)applicationFontMedium {
    return [self applicationFontWithSize:16];
}

+(UIFont *)applicationFontSmall {
    return [self applicationFontWithSize:14];
}

+(NSDateFormatter *)dateFormatterForRequest {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    
    return dateFormatter;
}

+(NSDateFormatter *)dateFormatterForDisplay {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    return dateFormatter;
}

@end
