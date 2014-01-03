#import "FacebookSignInButton.h"
#import "DataSyncUtility.h"
#import "FacebookUtils.h"

@implementation FacebookSignInButton {
    
    IBOutlet UIView *view;
    IBOutlet UILabel *facebookConnectText;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:view];
        [self addTapGesture];
        self.frame = CGRectSetSizeOnFrame(self.frame, view.frame.size);
        [self configureFacbookConnectText];
        
    }
    return self;
}

-(void)configureFacbookConnectText {
    facebookConnectText.font = [UIFont fontWithName:@"Cinzel-Regular" size:16.0];
}

-(void)addTapGesture {
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginWithFacebook)];
    
    [view addGestureRecognizer:tapGesture];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    view.frame = CGRectMakeFrameWithSizeFromFrame(frame);
    }

-(void)hide {
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    view.alpha = alpha;
}

-(void)loginWithFacebook {
    [FacebookUtils loginWithFacebook:^{
        [self hide];
    }];
}
@end
