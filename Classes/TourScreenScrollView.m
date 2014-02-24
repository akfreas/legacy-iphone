#import "TourScreenScrollView.h"

@interface TourScreenScrollView () <UIScrollViewDelegate>


@property UIView *backgroundView;
@property UIView *lockedForegroundView;
@property NSMutableArray *paginatedViews;

@end

@implementation TourScreenScrollView

- (id)initForAutoLayout
{
    self = [super initForAutoLayout];
    if (self) {
        // Initialization code
//        self.delegate = self;

        self.pagingEnabled = YES;
        self.paginatedViews = [NSMutableArray array];
        [self addPaginatedViews];
    }
    return self;
}

-(void)addBackgroundView {
    self.backgroundView = [[UIView alloc] initForAutoLayout];
    self.backgroundView.backgroundColor = [UIColor purpleColor];
    [self addSubview:self.backgroundView];
}

-(void)addLockedForegroundView {
    self.lockedForegroundView = [[UIView alloc] initForAutoLayout];
    self.lockedForegroundView.backgroundColor = [UIColor redColor];
    [self addSubview:self.lockedForegroundView];
}

//-(void)layoutSubviews {
//    CGSize contentSize = CGSizeMake(0, [[[UIApplication sharedApplication] keyWindow] frame].size.height);
//    for (UIView *page in self.paginatedViews) {
//        contentSize = CGSizeAddWidthToSize(contentSize, page.frame.size.width);
//    }
//    self.contentSize = contentSize;
//    [super layoutSubviews];
//}

-(void)addPaginatedViews {
    NSArray *imageFileNames = @[@"01.png", @"02.png", @"03.png", @"04.png"];
    NSMutableDictionary *bindingDict = [NSMutableDictionary dictionary];
    NSString *(^bindingNameForIndex)(NSInteger index) = ^(NSInteger index) {
        NSString *name = imageFileNames[index];
        NSString *formattedImageName = [NSString stringWithFormat:@"image_%@", [name stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
        return formattedImageName;
    };
    
    NSDictionary *(^bindingDictForImageWithIndex)(NSInteger index) = ^(NSInteger index) {;
        NSString *formattedImageName = bindingNameForIndex(index);
        UIImageView *imageView = self.paginatedViews[index];
        NSDictionary *bindings = @{formattedImageName: imageView};
        return bindings;
    };
    
    for (int i=0; i<[imageFileNames count]; i++) {
        NSString *image = imageFileNames[i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.paginatedViews addObject:imageView];
        [self addSubview:imageView];

        NSString *horizFormat;
        NSString *vertFormat;
        if (i > 0) {
            horizFormat = [NSString stringWithFormat:@"H:[%@][%@]", bindingNameForIndex(i - 1), bindingNameForIndex(i)];
        } else {
            horizFormat = [NSString stringWithFormat:@"H:|[%@]", bindingNameForIndex(i)];
        }
        vertFormat = [NSString stringWithFormat:@"V:|[%@]|", bindingNameForIndex(i)];
        [bindingDict addEntriesFromDictionary:bindingDictForImageWithIndex(i)];
        [self addConstraintWithVisualFormat:horizFormat bindings:bindingDict];
        [self addConstraintWithVisualFormat:vertFormat bindings:bindingDict];
    }
    
    UIView *lastFrame = [self.paginatedViews lastObject];
    
    [self addConstraintWithVisualFormat:@"H:[lastFrame]|" bindings:MXDictionaryOfVariableBindings(lastFrame)];
    
    UIButton *btn = [[UIButton alloc] initForAutoLayout];
    [btn setTitle:@"Start Now" forState:UIControlStateNormal];
    btn.backgroundColor = AppLightBlueColor;
    btn.titleLabel.font = StartNowButtonFont;
    [btn bk_addEventHandler:^(id sender) {
        self.scrollEnabled = NO;
            [NotificationUtils dismissTourScreen];
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:lastFrame attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:lastFrame attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:lastFrame attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-57.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:71.0f]];
    [self layoutIfNeeded];
}

-(BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if (view) {
        return YES;
    }
    return NO;
}

-(void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
}

@end
