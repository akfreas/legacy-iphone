#import "Event.h"
#import "Figure.h"
#import "LegacyWebView.h"
#import "WebViewControls.h"
#import "EventPersonRelation.h"

@interface LegacyWebView () <WebViewControlDelegate>
@end

@implementation LegacyWebView {
    
    IBOutlet UIWebView *webView;
    BOOL hasRenderedInitialHtml;
    BOOL viewHasBecomeFullyVisible;
    NSOperationQueue *queue;
    
    NSString *initialHtmlString;
    NSURL *baseUrl;
    NSURL *initialClickedLinkUrl;
    WebViewControls *controls;
}


-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"LegacyWebView" owner:self options:nil];
        controls = [[WebViewControls alloc] initWithOrigin:CGPointMake(0, 0)];
        controls.delegate = self;
        queue = [[NSOperationQueue alloc] init];
        webView.scrollView.delegate = self;
        controls.hideBackButton = YES;
        controls.hideForwardButton = YES;
        [self addSubview:webView];
    }
    return self;
}

-(void)loadRequest {
    
    if (hasRenderedInitialHtml == NO) {
        
        NSString *nameWithUnderscores = [_relation.event.figure.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", nameWithUnderscores]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:baseUrl];
        [request addValue:@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341" forHTTPHeaderField:@"User-Agent"];
        [controls startActivityIndicator];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *htmlData, NSError *error) {
            
            initialHtmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
            
            if (viewHasBecomeFullyVisible == YES && hasRenderedInitialHtml == NO) {
                [self loadInitialState];
            }
            [controls stopActivityIndicator];
        }];
    }
}

-(UIScrollView *)scrollView {
    return webView.scrollView;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    webView.frame = CGRectMakeFrameWithSizeFromFrame(frame);
}

-(void)addWebViewControls {
    if (controls.superview == nil) {
        [self insertSubview:controls aboveSubview:webView];
    }
    [UIView animateWithDuration:1 animations:^{
        controls.alpha = 1;
    }];
}

-(void)removeWebViewControls {
    
    if (controls != nil) {
        [UIView animateWithDuration:1 animations:^{
            controls.alpha = 0;
        } completion:^(BOOL finished) {
            //            [controls removeFromSuperview];
        }];
    }
}

-(void)setRelation:(EventPersonRelation *)relation {
    _relation = relation;
    [self loadRequest];
}

-(void)loadInitialState {
    if (hasRenderedInitialHtml == NO && initialHtmlString != nil) {
        [self renderInitialHtml];
        hasRenderedInitialHtml = YES;
    }
}

-(void)renderInitialHtml {
    [webView loadHTMLString:initialHtmlString baseURL:baseUrl];
}

#pragma mark PageProtocol Delegate Methods

-(void)becameVisible {
    [self loadInitialState];
}

-(void)scrollCompleted {
    [self addWebViewControls];
    
    if (viewHasBecomeFullyVisible == NO && hasRenderedInitialHtml == NO) {
        viewHasBecomeFullyVisible = YES;
        [self loadInitialState];
    }
    
}

#pragma mark WebViewControl Delegate

-(void)backButtonPressed {
    
    if (webView.canGoBack) {
        [webView goBack];
    } else {
        controls.hideBackButton = YES;
        controls.hideForwardButton = NO;
        [self renderInitialHtml];
    }
}

-(void)forwardButtonPressed {
    
    
    if (webView.canGoForward) {
        controls.hideBackButton = NO;
        [webView goForward];
    } else if (initialClickedLinkUrl != nil) {
        controls.hideBackButton = NO;
        controls.hideForwardButton = YES;
        initialClickedLinkUrl = nil;
        [webView loadRequest:[NSURLRequest requestWithURL:initialClickedLinkUrl]];
    }
}

#pragma mark UIWebViewDelegate

-(BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        controls.hideBackButton = NO;
        if (initialClickedLinkUrl == nil) {
            initialClickedLinkUrl = request.URL;
        }
    }
    
    if (navigationType == UIWebViewNavigationTypeBackForward) {
//        controls.hideForwardButton = !webView.canGoForward;
    }
    
    return YES;
}


-(void)webViewDidStartLoad:(UIWebView *)webView {
    [controls startActivityIndicator];
}


-(void)webViewDidFinishLoad:(UIWebView *)theWebView {
    [controls stopActivityIndicator];
}

@end
