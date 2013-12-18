#import "UIView+LayoutHelpers.h"

@implementation NSDictionary (MXConstraint)

+(NSDictionary *)MXTranslateAutoresizingMaskIntoConstraints:(NSDictionary *)bindings
{
    for (id key in bindings)
    {
        UIView *view = (UIView *)[bindings objectForKey:key];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return bindings;
}

@end

#pragma mark -
@implementation UIView (LayoutHelpers)

- (NSArray *)addConstraintWithVisualFormat:(NSString *)format bindings:(NSDictionary *)bindings
{
   NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                            options:0
                                            metrics:nil
                                              views:bindings];
    [self addConstraints:constraints];
    return constraints;
}

@end
