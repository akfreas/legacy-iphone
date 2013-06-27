#import "FigureRowPageProtocol.h"

@class Event;

@interface AtYourAgeWebView : UIView <UIWebViewDelegate, FigureRowPageProtocol>

@property (nonatomic) Event *event;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (copy) void(^loadingCompleteBlock)();

-(void)loadRequest;

@end
