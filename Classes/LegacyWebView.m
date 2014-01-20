#import "Event.h"
#import "Figure.h"
#import "LegacyWebView.h"
#import "WebViewControls.h"
#import "EventPersonRelation.h"
#import <TFHpple.h>

@interface LegacyWebView () <WebViewControlDelegate>
@end

@implementation LegacyWebView {
    
    UIWebView *webView;
    BOOL hasRenderedInitialHtml;
    BOOL viewHasBecomeFullyVisible;
    NSOperationQueue *queue;
    
    NSMutableString *initialHtmlString;
    NSURL *baseUrl;
    NSURL *initialClickedLinkUrl;
    WebViewControls *controls;
    TFHpple *hppleParser;
}


-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        queue = [[NSOperationQueue alloc] init];
        webView.scrollView.delegate = self;
    }
    return self;
}

-(void)layoutSubviews {
    if (webView == nil) {
        [self addWebView];
        [self addWebViewControls];
        [self addLayoutConstraints];
    }
    [super layoutSubviews];
}

-(void)addWebView {
    webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    webView.delegate = self;
    [self addSubview:webView];
}

-(void)addLayoutConstraints {
    UIBind(controls, webView);
    [self addConstraintWithVisualFormat:@"H:|[controls]|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:|[controls][webView]|" bindings:BBindings];
    [self addConstraintWithVisualFormat:@"H:|[webView]|" bindings:BBindings];
}

-(void)loadRequest {
    
    if (hasRenderedInitialHtml == NO) {
        
        NSString *nameWithUnderscores = [_relation.event.figure.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        baseUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", nameWithUnderscores]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:baseUrl];
        [request addValue:@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341" forHTTPHeaderField:@"User-Agent"];
        [controls startActivityIndicator];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *htmlData, NSError *error) {
            initialHtmlString = [[NSMutableString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
            if ([initialHtmlString length] > 0) {
                [initialHtmlString replaceOccurrencesOfString:@"<div class=\"header\">" withString:@"<div class=\"header\" style=\"display:none\">" options:0 range:NSMakeRange(0, [initialHtmlString length] - 1)];
                
                [initialHtmlString replaceOccurrencesOfString:@"<ul id=\"page-actions\" class=\"hlist\">" withString:@"<ul id=\"page-actions\" class=\"hlist\" style=\"display:none\">" options:0 range:NSMakeRange(0, [initialHtmlString length] - 1)];
                [initialHtmlString replaceOccurrencesOfString:@"<h1 id=\"section_0\">" withString:@"<h1 id=\"section_0\" style=\"display:none\">" options:0 range:NSMakeRange(0, [initialHtmlString length] - 1)];
            }
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
    
    webView.frame = CGRectOffset(CGRectMakeFrameWithSizeFromFrame(frame), 0, controls.frame.size.height);
}

-(void)addWebViewControls {
    if (controls == nil) {
        controls = [[WebViewControls alloc] initWithFrame:CGRectZero];
        controls.delegate = self;
        controls.hideBackButton = YES;
        controls.hideForwardButton = YES;
        
        [self insertSubview:controls aboveSubview:webView];
        
    }
    controls.figure = _relation.event.figure;
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
