#import "AgeArticleView.h"
#import "YardstickConnection.h"
#import "YardstickRequest.h"
#import "Event.h"
#import "Person.h"

@implementation AgeArticleView {
    
    IBOutlet UIWebView *storyWebView;
    
    User *user;
    __block Event  *event;
    NSDate *birthday;
}

- (id)initWithPerson:(User *)theUser {
    
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

-(void)updateWithPerson:(User *)theUser {
    user = theUser;
    [self getEventForBirthday];
}

-(void)getEventForBirthday {
    
    YardstickRequest *request = [YardstickRequest requestToGetStoryForPerson:user];
    [storyWebView loadRequest:request.urlRequest];

//    self.backgroundColor = [UIColor redColor];
}

#pragma mark UIWebView Delegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
}

@end
