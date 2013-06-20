@class Event;

@interface FigureRowActionOverlay : UIView

@property CGFloat animationDuration;

-(id)initWithEvent:(Event *)theEvent;
-(void)showInView:(UIView *)superView;
-(void)hide;

@end
