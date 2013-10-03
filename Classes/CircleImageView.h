@interface CircleImageView : UIView

@property (nonatomic) UIImage *image;
@property (assign, nonatomic) CGFloat radius;
@property (assign) CGRect frame;
@property (assign, nonatomic) CGFloat borderWidth;

-(id)initWithImage:(UIImage *)theImage radius:(CGFloat)theRadius;


@end
