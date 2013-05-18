@interface ImageWidget : UIView

-(id)initWithSmallImage:(UIImage *)theSmallImage largeImage:(UIImage *)theLargeImage;

@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat smallImageRadius;
@property (nonatomic, assign) CGFloat largeImageRadius;
@property (nonatomic, assign) CGFloat smallImageOffset;
@property (nonatomic) UIImage *smallImage;
@property (nonatomic) UIImage *largeImage;
@property (nonatomic) BOOL expanded;


@property (readonly) CGRect largeImageFrame;

@end
