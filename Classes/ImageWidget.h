@interface ImageWidget : UIView

-(id)initWithSmallImage:(UIImage *)theSmallImage largeImage:(UIImage *)theLargeImage;

@property (nonatomic, assign) CGFloat angle;

@end
