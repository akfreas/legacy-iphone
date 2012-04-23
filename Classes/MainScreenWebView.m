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
        
        UILabel *homeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 24)];
        
        homeLabel.text = @"Home";
        homeLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
        homeLabel.backgroundColor = [UIColor clearColor];
        homeLabel.textAlignment = UITextAlignmentCenter;
        
        homeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 44, 0, 44, 24)];
        homeButton.backgroundColor = [UIColor grayColor];
        homeButton.alpha = 0.75;

        [homeButton addTarget:self action:@selector(homeButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
        [homeButton.layer setCornerRadius:7.0];
        [homeButton addSubview:homeLabel];
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