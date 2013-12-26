
@interface ImageWidget : UIView

-(id)initWithSmallImage:(UIImage *)theSmallImage largeImage:(UIImage *)theLargeImage;

@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat smallImageRadius;
@property (nonatomic, assign) CGFloat largeImageRadius;
@property (nonatomic, assign) CGFloat smallImageBorderWidth;
@property (nonatomic, assign) CGFloat largeImageBorderWidth;
@property (nonatomic, strong) UIColor *smallImageBorderColor;
@property (nonatomic, strong) UIColor *largeImageBorderColor;
@property (nonatomic, assign) CGFloat smallImageOffset;
@property (nonatomic) UIImage *smallImage;
@property (nonatomic) UIImage *largeImage;

@end
