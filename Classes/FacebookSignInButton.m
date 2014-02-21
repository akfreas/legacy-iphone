#import "FacebookSignInButton.h"
#import "DataSyncUtility.h"
#import "FacebookUtils.h"

@implementation FacebookSignInButton {
    
    IBOutlet UIView *view;
    IBOutlet UILabel *facebookConnectText;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:view];
        [self addTapGesture];
        self.frame = CGRectSetSizeOnFrame(self.frame, view.frame.size);
        [self configureFacebookConnectText];
        
    }
    return self;
}

-(void)configureFacebookConnectText {
    [self setImage:FacebookInfoPageButton forState:UIControlStateNormal];
}

-(void)addTapGesture {
    [self bk_addEventHandler:^(id sender) {
        
        [FacebookUtils loginWithFacebook:^{
            [self hide];
        }];
    } forControlEvents:UIControlEventTouchUpInside];
}

-(void)hide {
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
