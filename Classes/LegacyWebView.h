#import "PageProtocol.h"

@class EventPersonRelation;

@interface LegacyWebView : UIView <UIWebViewDelegate, UIScrollViewDelegate, PageProtocol>

@property (nonatomic) EventPersonRelation *relation;
@property (nonatomic, readonly) UIScrollView *scrollView;

-(void)loadRequest;

@end
