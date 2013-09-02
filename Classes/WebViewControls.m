#import "WebViewControls.h"


@implementation WebViewControls {
    
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *forwardButton;
    IBOutlet UIActivityIndicatorView *indicatorView;

}

- (id)initWithOrigin:(CGPoint)origin
{
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil][0];
    if (self) {
        self.frame = CGRectSetOriginOnRect(self.frame, origin.x, origin.y)
        ;
        indicatorView.hidden = YES;
    }
    return self;
}

-(IBAction)backButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(backButtonPressed)]) {
        [self.delegate backButtonPressed];
    }
}

-(IBAction)forwardButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(forwardButtonPressed)]) {
        [self.delegate forwardButtonPressed];
    }
}
-(void)setHideBackButton:(BOOL)hideBackButton {
    backButton.hidden = hideBackButton;
}

-(void)setHideForwardButton:(BOOL)hideForwardButton {
    forwardButton.hidden = hideForwardButton;
}
-(void)startActivityIndicator {
    indicatorView.hidden = NO;
    [indicatorView startAnimating];
}

-(void)stopActivityIndicator {
    indicatorView.hidden = YES;
    [indicatorView stopAnimating];
}

@end
