#import "FigureRowPageProtocol.h"

@class Event;

@interface AtYourAgeWebView : UIView <UIWebViewDelegate, FigureRowPageProtocol>

@property (nonatomic) Event *event;

-(void)loadRequest;

@end
