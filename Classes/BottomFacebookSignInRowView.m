#import "BottomFacebookSignInRowView.h"
#import "ObjectArchiveAccessor.h"
#import "DataSyncUtility.h"

@implementation BottomFacebookSignInRowView {
    
    IBOutlet UIView *view;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
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
    
//    [[NSUserDefaults standardUserDefaults] setValue:@"CAABr4W3cfKwBAL3Us8sCZB7GCfJe0AyAuXjhhmNy5pFYeGfsuMs0QTgMjrDJpodahFQFIMt3PuTgrSD2zszYZAh0hBobYeJTEGZCb5v2elPrGmbRbgnTvNR2MLhS7sbp4NqdHmEoozYgQiazfiDj7nXndBeWCj13iHZBSfcgKQZDZD" forKey:@"FBAccessTokenInformationKey"];
    if ([[FBSession activeSession] isOpen] == NO) {
        if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
            [FBSession openActiveSessionWithAllowLoginUI:NO];
            [self hide];
        } else {
            [self startFBLoginProcess];
        }
    }
}

-(void)startFBLoginProcess {
//    
//    NSDictionary *accessToken = @{
//                                  @"com.facebook.sdk:TokenInformationExpirationDateKey" : [NSDate distantFuture],
//                                  @"com.facebook.sdk:TokenInformationIsFacebookLoginKey" : [NSNumber numberWithInt:1],
//                                  @"com.facebook.sdk:TokenInformationLoginTypeLoginKey" : [NSNumber numberWithInt:3],
//                                  @"com.facebook.sdk:TokenInformationPermissionsKey" :     @[
//                                          @"user_birthday",
//                                          @"friends_birthday"
//                                          ],
//                                  @"com.facebook.sdk:TokenInformationRefreshDateKey" : [NSDate date],
//                                  @"com.facebook.sdk:TokenInformationTokenKey" : @"CAABr4W3cfKwBABZBAVmuUjZCJPmR7ZAfhOmvAOozxmOUzAtHumi8ZBXI26fiHd8iPvTS6uUqZAmxNsaM17Qjfz5kDZBNoEJjlWXZBo4ISguulPuNHPCmTywq1De58Tww1hK1wZANAfTILnikQe8FIa7IBcXLRr4XDNihNha5NytppwZDZD"
//                                  };
//    
//    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"FBAccessTokenInformationKey"];
    FBSession *session = [[FBSession alloc] initWithPermissions:@[@"user_birthday", @"friends_birthday"]];
    [FBSession setActiveSession:session];
    
    [session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (status == FBSessionStateOpen) {
            [self getAndSavePrimaryUser];
        }
    }];
}

-(void)getAndSavePrimaryUser {
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> result, NSError *error) {
        [[ObjectArchiveAccessor sharedInstance] createAndSetPrimaryUser:result completionBlock:^(Person *thePerson) {
            [self hide];
            [[DataSyncUtility sharedInstance] sync:^{
            }];
        }];
    }];
}

@end
