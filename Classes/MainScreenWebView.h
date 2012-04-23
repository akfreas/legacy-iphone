@class Event;



@interface MainScreenWebView : UIWebView <UIWebViewDelegate>

-(id)initWithEvent:(Event *)theEvent;
-(void)updateWithEvent:(Event *)theEvent;

@end
