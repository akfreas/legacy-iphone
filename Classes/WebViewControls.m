#import "WebViewControls.h"

@protocol WebViewControlDelegate <NSObject>

@required

-(void)backButtonPressed;
-(void)forwardButtonPressed;

@end

@implementation WebViewControls

- (id)initWithOrigin:(CGPoint)origin
{
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil][0];
    if (self) {
        self.frame = CGRectSetOriginOnRect(self.frame, origin.x, origin.y);
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

@end
