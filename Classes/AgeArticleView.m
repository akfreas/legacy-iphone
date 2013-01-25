#import "AgeArticleView.h"
#import "AtYourAgeConnection.h"
#import "AtYourAgeRequest.h"
#import "Event.h"
#import "User.h"

@implementation AgeArticleView {
    
    IBOutlet UIWebView *storyWebView;
    
    User *user;
    __block Event  *event;
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


-(void)awakeFromNib {
    [super awakeFromNib];
    storyWebView.delegate = self;

//    [[NSBundle mainBundle] loadNibNamed:@"AgeArticleView" owner:self options:nil];
}

-(void)updateWithUser:(User *)theUser {
    user = theUser;
    [self getEventForBirthday];
}

-(void)getEventForBirthday {
    
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetStoryForUser:user];
    [storyWebView loadRequest:request.urlRequest];

//    self.backgroundColor = [UIColor redColor];
}

#pragma mark UIWebView Delegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"Started");
}

@end
