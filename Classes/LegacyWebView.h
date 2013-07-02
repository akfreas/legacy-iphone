#import "FigureRowPageProtocol.h"

@class Event;

@interface LegacyWebView : UIView <UIWebViewDelegate, UIScrollViewDelegate, FigureRowPageProtocol>

@property (nonatomic) Event *event;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (copy) void(^loadingCompleteBlock)();

-(void)loadRequest;

@end
