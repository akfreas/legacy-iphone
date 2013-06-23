//
//  BottomFacebookSignInRowView.m
//  AtYourAge
//
//  Created by Alexander Freas on 6/23/13.
//
//

#import "BottomFacebookSignInRowView.h"

@implementation BottomFacebookSignInRowView {
    
    IBOutlet UIView *view;
}

-(id)init {
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:view];
        [self addTapGesture];
        self.frame = CGRectSetSizeOnFrame(self.frame, view.frame.size);
    }
    return self;
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
    
    CGSize sizeChange = CGSizeMake(0, -self.frame.size.height);
    NSDictionary *dict = @{@"animation_duration" : [NSNumber numberWithFloat:0.5], @"size_change" : [NSValue valueWithCGSize:sizeChange]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForFigureRowContentChanged object:self userInfo:dict];
}

-(void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
    view.alpha = alpha;
}

-(void)loginWithFacebook {
    if ([[FBSession activeSession] isOpen] == NO) {
        if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
            [FBSession openActiveSessionWithAllowLoginUI:NO];
        } else {
            FBSession *session = [[FBSession alloc] initWithPermissions:@[@"user_birthday", @"friends_birthday"]];
            [FBSession setActiveSession:session];
            [session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
               
                
                if (status == FBSessionStateOpen) {
                    [self hide];
                }
            }];
        }
    }
}

@end
