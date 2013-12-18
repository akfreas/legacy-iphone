#import "PageProtocol.h"

@class Event;

@interface LegacyWebView : UIView <UIWebViewDelegate, UIScrollViewDelegate, PageProtocol>

@property (nonatomic) Event *event;
@property (nonatomic, readonly) UIScrollView *scrollView;
//@property (copy) void(^loadingCompleteBlock)();

-(void)loadRequest;

@end
