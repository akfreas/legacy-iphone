#import "Event.h"
#import "Figure.h"
#import "AtYourAgeWebView.h"

@implementation AtYourAgeWebView {
    
    IBOutlet UIWebView *webView;
    BOOL hasLoadedEventInfo;
    NSOperationQueue *queue;
}


-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSBundle mainBundle] loadNibNamed:@"AtYourAgeWebView" owner:self options:nil];
        queue = [[NSOperationQueue alloc] init];
        webView.scrollView.delegate = self;
        [webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        [self addSubview:webView];
        [[[webView subviews] lastObject] setScrollEnabled:NO];
    }
    return self;
}

-(void)loadRequest {
    
    if (_event != nil && hasLoadedEventInfo == NO) {
    
        NSString *nameWithUnderscores = [_event.figure.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", nameWithUnderscores]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request addValue:@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341" forHTTPHeaderField:@"User-Agent"];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *htmlData, NSError *error) {
            
            NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
            [webView loadHTMLString:htmlString baseURL:url];
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

-(CGFloat)rightPageMargin {
    return 10;
}

#pragma mark UIViewController Methods


#pragma mark UIWebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    UIScrollView *scrollView = (UIScrollView *)object;
    NSLog(@"new: %@", CGSizeCreateDictionaryRepresentation( scrollView.contentSize));
    self.frame = CGRectSetSizeOnFrame(self.frame, scrollView.contentSize);
}

-(void)webViewDidFinishLoad:(UIWebView *)theWebView {
    hasLoadedEventInfo = YES;
    self.frame = CGRectSetSizeOnFrame(self.frame, CGSizeMake(self.bounds.size.width, webView.scrollView.contentSize.height));
    if (_loadingCompleteBlock != NULL) {
        _loadingCompleteBlock();
    }
}

@end
