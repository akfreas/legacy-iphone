#import "Event.h"
#import "AtYourAgeWebView.h"

@implementation AtYourAgeWebView {
    
    Event *event;
    
    IBOutlet UIWebView *webView;
}


-(id)initWithEvent:(Event *)theEvent {
    
    self = [super initWithNibName:@"AtYourAgeWebView" bundle:[NSBundle mainBundle]];
    if (self) {
        event = theEvent;
    }
    return self;
}

-(void)startWebViewWithRequest {
    
    
    NSString *nameWithUnderscores = [event.figureName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", nameWithUnderscores]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [webView loadRequest:request];
}

#pragma mark UIViewController Methods

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self startWebViewWithRequest];
}

#pragma mark UIWebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

@end
