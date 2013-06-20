@interface CircleImageView : UIView

@property (nonatomic) UIImage *image;
@property (assign) CGFloat radius;
@property (assign) CGRect frame;

-(id)initWithImage:(UIImage *)theImage radius:(CGFloat)theRadius;


@end
