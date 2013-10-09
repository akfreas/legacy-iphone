#import "AMBlurView.h"

@class EventPersonRelation;

@interface SwipeMessage : NSObject

-(void)setEventRelation:(EventPersonRelation *)relation cellOrigin:(CGPoint)point;

-(id)initWithSuperView:(UIView *)view;
-(void)show;

@end
