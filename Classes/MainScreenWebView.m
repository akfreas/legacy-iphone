#import "MainScreenWebView.h"
#import "Event.h"


typedef enum  {
    BrowserLocationNotLoaded = 0,
    BrowserLocationAtHome = 1,
    BrowserLocationBrowsing = 2
} BrowserState;

@implementation MainScreenWebView {
    
    Event *event;
    BrowserState browserState;
    UIButton *homeButton;
    
    BOOL atHome;
}

- (id)initWithEvent:(Event *)theEvent {
    self = [super init];
    
    if (self) {
        event = theEvent;
        self.delegate = self;
        browserState = BrowserLocationNotLoaded;
        [self loadInitialHtml];
    }
    
    return self;
}



-(void)updateWithEvent:(Event *)theEvent {
    event = theEvent;
    [self loadInitialHtml];
}

-(void)loadInitialHtml {
    
    NSString *nameWithUnderscores = [event.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *nameWithHttpLink = [NSString stringWithFormat:@"<a href=\"http://en.wikipedia.org/wiki/%@\">%@</a>", nameWithUnderscores, event.name];
    
    
    NSString *genderQualifier;
    
    if (event.male) {
        genderQualifier = @"he";
    } else {
        genderQualifier = @"she";
    }
    
    NSString *htmlString = [NSString stringWithFormat:@"When %@ was your age, %@ %@", nameWithHttpLink, genderQualifier, event.eventDescription];
    browserState = BrowserLocationAtHome;
    [self loadHTMLString:htmlString baseURL:nil];
    

}

-(void)homeButtonWasTapped {
    [self loadInitialHtml];
}

-(void)placeHomeButton {
    
    if (homeButton == nil) {
        homeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 20, 0, 20, 20)];
        homeButton.backgroundColor = [UIColor redColor];
        [homeButton setTitle:@"Home" forState:UIControlStateNormal];
        [homeButton addTarget:self action:@selector(homeButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    } 
    [self addSubview:homeButton];
    homeButton.hidden = NO;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (request.URL.path == nil) {
    
        if (browserState == BrowserLocationNotLoaded) {
            [self loadInitialHtml];
        } else {
            [homeButton removeFromSuperview];
            browserState = BrowserLocationBrowsing;
            homeButton.hidden = YES;
        }
    } else {
        [self placeHomeButton];
    }
    
    NSLog(@"REquest: %@", request.URL.path);
    
    return YES;
}

@end