#import "FigureRowHorizontalScrollView.h"
#import "FigureRowContentView.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "Figure.h"
#import "Event.h"
#import "Person.h"

@interface FigureRowHorizontalScrollView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation FigureRowHorizontalScrollView {
    
    FigureRowContentView *figureContentView;

    UILabel *figureNameLabel;
    UIPageControl *pageControl;
    NSMutableArray *pageArray;
    UIView *nameContainerView;
    
    CGPoint lastPoint;
    BOOL isNonUserScrolling;
    
    UIButton *facebookButton;
    UISwipeGestureRecognizer *swipeGestureRecognizer;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.bounces = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.scrollEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addContentView];
        [self registerForNotifications];
    }
    return self;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (isNonUserScrolling == YES) {
        return;
    }
    if (scrollView.contentOffset.x > DrawerWidth / 2) {
        [self closeDrawer:NULL];
    } else {
        [self openDrawer];
    }
}

#pragma mark Gesture Recognizer Methods
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint newPoint = [figureContentView convertPoint:point fromView:self];
    return [figureContentView pointInside:newPoint withEvent:event];
}


-(void)setContentSize:(CGSize)contentSize {
    if (contentSize.width <= self.intrinsicContentSize.width) {
        contentSize = CGSizeAddWidthToSize(contentSize, DrawerWidth);
    }
    self.contentOffset = CGPointMake(DrawerWidth, 0);
    [super setContentSize:contentSize];
}

-(void)delayedReset {
    [self performSelector:@selector(resetContentOffset) withObject:self afterDelay:.2];
}

-(void)closeDrawer:(void(^)())completion {
    
    [UIView animateWithDuration:0.2 animations:^{
        isNonUserScrolling = YES;
        self.contentOffset = CGPointMake(DrawerWidth, 0);
    } completion:^(BOOL finished) {
        if (finished) {
            isNonUserScrolling = NO;
            if (completion != NULL) {
                completion();
            }
        }
    }];
}

-(void)openDrawer {
    
    [UIView animateWithDuration:0.2 animations:^{
        isNonUserScrolling = YES;
        self.contentOffset = CGPointMake(0, 0);
    } completion:^(BOOL finished) {
        isNonUserScrolling = NO;
    }];
}

-(void)registerForNotifications {
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeActionOverlay:) name:KeyForOverlayViewShown object:nil];
    
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Accessors

-(void)setEvent:(Event *)event {
    
    _event = event;
    if (event != nil) {
        figureContentView.event = event;
    }
}

-(void)setPerson:(Person *)person {
    _person = person;
    figureContentView.person = person;
}

-(CGSize)intrinsicContentSize {
    return figureContentView.intrinsicContentSize;
}

#pragma mark Page Management

-(void)addContentView {
    figureContentView = [[FigureRowContentView alloc] initWithFrame:CGRectZero];
    [self addSubview:figureContentView];
    UIBind(figureContentView);
    [self addConstraintWithVisualFormat:[NSString stringWithFormat:@"H:|-%d-[figureContentView]|", DrawerWidth] bindings:BBindings];
    [self addConstraintWithVisualFormat:@"V:|[figureContentView]|" bindings:BBindings];
}


@end