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
        figureContentView = [[EventRowContentView alloc] initForAutoLayout];
    
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.bounces = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.contentSize = CGSizeAddWidthToSize(figureContentView.intrinsicContentSize, DrawerWidth);
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (isNonUserScrolling == YES) {
        return;
    }
    if (decelerate == NO) {
        if (scrollView.contentOffset.x > DrawerWidth / 2) {
            [self closeDrawer:NULL];
        } else {
            [self openDrawer];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[EventRowDrawerOpenBucket sharedInstance] closeDrawers:NULL];
    if (scrollView.contentOffset.x == 0) {
        [[EventRowDrawerOpenBucket sharedInstance] addRow:self];
    }
    if (scrollView.contentOffset.x == DrawerWidth) {
        [[EventRowDrawerOpenBucket sharedInstance] removeRow:self];
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
-(void)layoutSubviews {
    if (figureContentView.superview == nil) {
        self.contentSize = CGSizeAddWidthToSize(figureContentView.intrinsicContentSize, DrawerWidth);
        self.contentOffset = CGPointMake(DrawerWidth, 0);
        [self addContentView];
        [self addContentViewConstraints];
    }
    [super layoutSubviews];
}
#pragma mark Accessors


-(void)setRelation:(EventPersonRelation *)relation {
    _relation = relation;
    if (_relation.event == nil) {
        self.scrollEnabled = NO;
    } else {
        self.scrollEnabled = YES;
    }
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
    [self addConstraintWithVisualFormat:@"V:|[figureContentView]|" bindings:BBindings];
}

-(void)addContentView {
    [self addSubview:figureContentView];
}


@end