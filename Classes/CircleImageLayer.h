@interface CircleImageLayer : CALayer


@property (nonatomic) UIImage *image;


-(id)initWithRadius:(CGFloat)theRadius;
-(id)initWithImage:(UIImage *)theImage radius:(CGFloat)theRadius;

@end
