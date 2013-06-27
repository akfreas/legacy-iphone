#import "FigureRowPageProtocol.h"

@class Event;

@interface AtYourAgeWebView : UIView <UIWebViewDelegate, UIScrollViewDelegate, FigureRowPageProtocol>

@property (nonatomic) Event *event;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (copy) void(^loadingCompleteBlock)();

-(void)loadRequest;

@end
