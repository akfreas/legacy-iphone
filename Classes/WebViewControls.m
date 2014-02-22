#import "WebViewControls.h"
#import "Figure.h"


@implementation WebViewControls {
    
    UIButton *backButton;
    UIButton *forwardButton;
    UIButton *backPageButton;
    UIActivityIndicatorView *indicatorView;
    UILabel *titleLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = HeaderBackgroundColor;
        [backButton setImage:[self backButtonImage] forState:UIControlStateNormal];
        [backButton setTitle:@"" forState:UIControlStateNormal];
        [forwardButton setImage:[self forwardButtonImage] forState:UIControlStateNormal];
        [forwardButton setTitle:@"" forState:UIControlStateNormal];
        indicatorView.hidden = YES;
        
        [self addActivityIndicator];
        [self addBackPageButton];
        [self addTitleLabel];
        [self addLayoutConstraints];
    }
    return self;
}

-(void)addBackPageButton {
    backPageButton = [[UIButton alloc] initForAutoLayout];
    [backPageButton setImage:BackPageButtonImage forState:UIControlStateNormal];
    [backPageButton bk_addEventHandler:^(id sender) {
        [NotificationUtils scrollToPage:TimelinePageNumber];
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backPageButton];
    
}

-(CGSize)intrinsicContentSize {
    return CGSizeMake(320, 64);
}

-(void)addTitleLabel {
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:titleLabel];
    titleLabel.font = HeaderFont;
    titleLabel.textColor = HeaderTextColor;
}

-(void)setFigure:(Figure *)figure {
    titleLabel.text = figure.name;
}

-(void)addActivityIndicator {
    if (indicatorView == nil) {
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:indicatorView];
    }
}

-(void)addLayoutConstraints {
    
    [titleLabel autoCenterInSuperviewAlongAxis:ALAxisVertical];
    UIBind(titleLabel, indicatorView, backPageButton);
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:8]];
    [self addConstraintWithVisualFormat:@"H:[titleLabel]-10-[indicatorView]" bindings:BBindings];
    [indicatorView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:titleLabel];
    [self addConstraintWithVisualFormat:@"H:|[backPageButton(>=70)]" bindings:BBindings];
    [backPageButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:titleLabel];
}

- (UIImage *)forwardButtonImage
{
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        UIImage *backButtonImage = [self backButtonImage];
        
        CGSize size = backButtonImage.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat x_mid = size.width / 2.0;
        CGFloat y_mid = size.height / 2.0;
        
        CGContextTranslateCTM(context, x_mid, y_mid);
        CGContextRotateCTM(context, M_PI);
        
        [backButtonImage drawAtPoint:CGPointMake(-x_mid, -y_mid)];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (UIImage *)backButtonImage
{
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        CGSize size = CGSizeMake(12.0, 21.0);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 1.5;
        path.lineCapStyle = kCGLineCapButt;
        path.lineJoinStyle = kCGLineJoinMiter;
        [path moveToPoint:CGPointMake(11.0, 1.0)];
        [path addLineToPoint:CGPointMake(1.0, 11.0)];
        [path addLineToPoint:CGPointMake(11.0, 20.0)];
        [path stroke];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

-(IBAction)backButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(backButtonPressed)]) {
        [self.delegate backButtonPressed];
    }
}

-(IBAction)forwardButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(forwardButtonPressed)]) {
        [self.delegate forwardButtonPressed];
    }
}
-(void)setHideBackButton:(BOOL)hideBackButton {
    backButton.hidden = hideBackButton;
}

-(void)setHideForwardButton:(BOOL)hideForwardButton {
    forwardButton.hidden = hideForwardButton;
}
-(void)startActivityIndicator {
    indicatorView.hidden = NO;
    [indicatorView startAnimating];
}

-(void)stopActivityIndicator {
    indicatorView.hidden = YES;
    [indicatorView stopAnimating];
}

@end
