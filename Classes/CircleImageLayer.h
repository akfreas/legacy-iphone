@interface CircleImageLayer : CALayer


@property (nonatomic) UIImage *image;
@property (assign) CGFloat radius;
@property (assign) CGRect frame;
@property (assign) CGFloat borderWidth;


-(id)initWithRadius:(CGFloat)theRadius;
-(id)initWithImage:(UIImage *)theImage radius:(CGFloat)theRadius;

@end
