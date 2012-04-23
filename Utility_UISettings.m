#import "Utility_UISettings.h"

@implementation Utility_UISettings

+(UIFont *)applicationFontWithSize:(CGFloat)fontSize {
    
    UIFont *appFont = [UIFont fontWithName:@"AmericanTypeWriter" size:fontSize];
    
    return appFont;
}

+(UIFont *)applicationFontLarge {
    return [self applicationFontWithSize:16];
}

+(UIFont *)applicationFontMedium {
    return [self applicationFontWithSize:12];
}

+(UIFont *)applicationFontSmall {
    return [self applicationFontWithSize:10];
}

@end
