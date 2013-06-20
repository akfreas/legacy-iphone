@class Event;

@interface FigureRowActionOverlay : UIView

@property CGFloat animationDuration;
@property (copy) void(^facebookButtonAction)();
@property (copy) void(^infoButtonAction)();

-(id)initWithEvent:(Event *)theEvent;
-(void)showInView:(UIView *)superView;
-(void)hide;

@end
