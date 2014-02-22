#import "ButtonWithImageView.h"

@implementation ButtonWithImageView

-(UIView *)viewForBaselineLayout {
    return self.imageView;
}

-(void)configureForBackButton {
   [self setImage:[UIImage imageNamed:@"back-arrow"] forState:UIControlStateNormal];
}

-(void)configureForForwardButton {
    [self setImage:[UIImage imageNamed:@"next-arrow"] forState:UIControlStateNormal];
}

@end
