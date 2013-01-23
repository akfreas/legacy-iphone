#import "AgeArticleView.h"
#import "AtYourAgeConnection.h"
#import "AtYourAgeRequest.h"
#import "Event.h"
#import "User.h"

@implementation AgeArticleView {
    
    IBOutlet UIWebView *storyWebView;
    
    User *user;
    Event *event;
    NSDate *birthday;
}

- (id)initWithUser:(User *)theUser {
    
    self = [super init];
    if (self) {
        user = theUser;
        
        [[NSBundle mainBundle] loadNibNamed:@"AgeArticleView" owner:self options:nil];
    }
    return self;
}


-(void)updateWithUser:(User *)theUser {
    user = theUser;
    [self getEventForBirthday];
}

-(void)getEventForBirthday {
    
    [[FBRequest requestForGraphPath:user.facebookId] startWithCompletionHandler:^(FBRequestConnection *fbConnection, id <FBGraphUser> result, NSError *error) {
        
        AtYourAgeRequest *request = [AtYourAgeRequest requestToGetEventForUser:user];
        AtYourAgeConnection *connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
        
        [connection getWithCompletionBlock:^(AtYourAgeRequest *request, Event *theEvent, NSError *error) {
            event = theEvent;
            [storyWebView loadHTMLString:event.storyHtml baseURL:nil];
        }];
    }];
}

@end
