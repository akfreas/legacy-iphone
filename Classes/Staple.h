@interface Staple : UIView

-(id)initWithCenterPoint:(CGPoint)theCenterPoint angle:(CGFloat)theAngle length:(CGFloat)theLength;
-(id)initWithBeginPoint:(CGPoint)theBeginPoint endPoint:(CGPoint)theEndPoint;

@property (assign, setter = setAngle:) CGFloat angle;

@end
