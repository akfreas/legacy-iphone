#import "Event.h"
#import "Figure.h"
#import "AtYourAgeWebView.h"

@implementation AtYourAgeWebView {
    
    IBOutlet UIWebView *webView;
    BOOL hasLoadedEventInfo;
}


-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"AtYourAgeWebView" owner:self options:nil];

        [self addSubview:webView];
    }
    return self;
}

-(void)loadRequest {
    
    if (_event != nil && hasLoadedEventInfo == NO) {
    
        NSString *nameWithUnderscores = [_event.figure.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", nameWithUnderscores]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

        [webView loadRequest:request];
    }
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    webView.frame = CGRectMakeFrameWithSizeFromFrame(frame);
}

-(CGFloat)rightPageMargin {
    return 10;
}

#pragma mark UIViewController Methods


#pragma mark UIWebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    hasLoadedEventInfo = YES;
}

@end
