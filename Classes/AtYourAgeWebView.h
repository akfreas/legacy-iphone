#import "PersonRowPageProtocol.h"

@class Event;

@interface AtYourAgeWebView : UIView <UIWebViewDelegate, PersonRowPageProtocol>

@property (nonatomic) Event *event;

-(void)loadRequest;

@end
