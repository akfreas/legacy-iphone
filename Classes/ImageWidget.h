@interface ImageWidget : UIView

-(id)initWithSmallImage:(UIImage *)theSmallImage largeImage:(UIImage *)theLargeImage;

@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat smallImageRadius;
@property (nonatomic) UIImage *smallImage;
@property (nonatomic) UIImage *largeImage;

@end
