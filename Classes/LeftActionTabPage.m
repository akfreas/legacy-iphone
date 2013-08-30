#import "LeftActionTabPage.h"
#import "Person.h"

@implementation LeftActionTabPage {
    
    UIButton *deleteButton;
    UIButton *wikipediaButton;
    NSMutableArray *buttonArray;
}

NSInteger numberOfButtons = 2;

-(id)initWithOrigin:(CGPoint)origin height:(CGFloat)height {
    if (self == [super initWithFrame:CGRectMake(origin.x, origin.y, LeftActionTabPageWidth, height)]) {
        [self drawWikipediaButton];
    }
    return self;
}


-(void)setPerson:(Person *)person {
    _person = person;
    if ([_person.isPrimary isEqualToNumber: [NSNumber numberWithBool:NO]]) {
        [self drawDeleteButton];
    }
}


-(void)drawWikipediaButton {
    
    CGRect buttonFrame = [self rectForButtonAtIndex:2];
    wikipediaButton = [[UIButton alloc] initWithFrame:buttonFrame];
    UIImageView *trashCan = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wikipedia-icon.png"]];
    trashCan.frame = CGRectMakeFrameForDeadCenterInRect(wikipediaButton.frame, CGSizeMake(LeftActionTabPageButtonWidth - 5, LeftActionTabPageButtonWidth - 5));
    [wikipediaButton addSubview:trashCan];
    [wikipediaButton addTarget:self action:@selector(wikipediaButtonAction) forControlEvents:UIControlEventTouchUpInside];
    wikipediaButton.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:wikipediaButton];
}

-(CGRect)rectForButtonAtIndex:(NSInteger)index {
    
    CGFloat buttonOriginY = (LeftActionTabPageButtonHeight + 10) * (numberOfButtons - 1) * (index - 1);
    CGFloat buttonOriginAbsY = self.frame.size.height / 2 + buttonOriginY;
    CGRect buttonFrame = CGRectMake(0, buttonOriginAbsY, LeftActionTabPageButtonWidth, LeftActionTabPageButtonHeight);
    
    return buttonFrame;
}

-(void)drawDeleteButton {
    
    CGRect buttonFrame = [self rectForButtonAtIndex:1];
    deleteButton = [[UIButton alloc] initWithFrame:buttonFrame];
    UIImageView *trashCan = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"218-trash2.png"]];
    trashCan.frame = CGRectMakeFrameForDeadCenterInRect(deleteButton.frame, trashCan.frame.size);
    [deleteButton addSubview:trashCan];
    [deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.backgroundColor = [UIColor whiteColor];

    [self addSubview:deleteButton];
}

-(void)deleteButtonAction {
    if (_person != nil) {
        NSDictionary *userInfo = @{@"person" : _person};
        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForRemovePersonButtonTappedNotification object:self userInfo:userInfo];
    }
}

-(void)wikipediaButtonAction {
    
    NSDictionary *userInfo = @{@"event": _event};
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForWikipediaButtonTappedNotification object:self userInfo:userInfo];
}

-(void)setHeight:(CGFloat)height {
    self.frame = CGRectSetHeightForRect(height, self.frame);
    [self setNeedsLayout];
}

-(void)layoutSubviews {
    
    [super setNeedsLayout];
    for (int i=0; i < [buttonArray count]; i++) {
        UIButton *button = [buttonArray objectAtIndex:i];
        button.frame = [self rectForButtonAtIndex:i];
    }
}

#pragma mark FigureRowPageProtocol Functions

-(CGFloat)rightPageMargin {
    return 0;
}

@end
