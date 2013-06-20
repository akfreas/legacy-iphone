@class Event;

@interface FigureRowActionOverlay : UIView

-(id)initWithEvent:(Event *)theEvent;
-(void)showInView:(UIView *)superView;

@end
