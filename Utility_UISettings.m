#import "Utility_UISettings.h"

@implementation Utility_UISettings

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

@end
