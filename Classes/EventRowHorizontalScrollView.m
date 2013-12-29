#import "EventRowHorizontalScrollView.h"
#import "EventRowContentView.h"
#import "LegacyAppRequest.h"
#import "LegacyAppConnection.h"
#import "Figure.h"
#import "Event.h"
#import "Person.h"
#import "EventRowDrawerOpenBucket.h"

@interface EventRowHorizontalScrollView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation EventRowHorizontalScrollView {
    
    EventRowContentView *figureContentView;
    UIView *nameContainerView;
    BOOL isNonUserScrolling;
    
}

- (id)initForAutoLayout {
    self = [super initForAutoLayout];
    if (self) {
        [self addContentView];
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.bounces = NO;
        self.backgroundColor = [UIColor clearColor];
        self.contentSize = CGSizeAddWidthToSize(figureContentView.intrinsicContentSize, DrawerWidth);
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addContentViewConstraints];
        [self layoutIfNeeded];
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
    [[EventRowDrawerOpenBucket sharedInstance] addRow:self];
    [UIView animateWithDuration:0.2 animations:^{
        isNonUserScrolling = YES;
        self.contentOffset = CGPointMake(0, 0);
    } completion:^(BOOL finished) {
        isNonUserScrolling = NO;
    }];
}

#pragma mark Accessors


-(void)setRelation:(EventPersonRelation *)relation {
    _relation = relation;
    figureContentView.relation = _relation;
}

-(CGSize)intrinsicContentSize {
    CGSize contentSize = CGSizeAddWidthToSize(figureContentView.intrinsicContentSize, 0);
    return contentSize;
}

#pragma mark Page Management
-(void)addContentViewConstraints {
    
    UIBind(figureContentView);
    [self addConstraintWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[figureContentView(320)]|", DrawerWidth] bindings:BBindings];
    //    [self addConstraintWithVisualFormat:@"H:|[figureContentView(>=320)]|" bindings:BBindings];
    
    [self addConstraintWithVisualFormat:@"V:|[figureContentView]|" bindings:BBindings];
    [self closeDrawer:NULL];
    
}
-(void)addContentView {
    figureContentView = [[EventRowContentView alloc] initForAutoLayout];
    [self addSubview:figureContentView];
    self.contentSize = CGSizeAddWidthToSize(figureContentView.intrinsicContentSize, DrawerWidth);
}


@end