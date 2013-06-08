#import "LeftActionTabPage.h"

@implementation LeftActionTabPage {
    
    UIButton *deleteButton;
    NSMutableArray *buttonArray;
}

NSInteger numberOfButtons = 1;

-(id)initWithOrigin:(CGPoint)origin height:(CGFloat)height {
    if (self == [super initWithFrame:CGRectMake(origin.x, origin.y, LeftActionTabPageWidth, height)]) {
        [self drawDeleteButton];
    }
    return self;
}


-(void)drawDeleteButton {
    
    
    CGFloat buttonOriginY = self.frame.size.height / (numberOfButtons + 1) - LeftActionTabPageButtonHeight / 2;
    CGRect buttonFrame = CGRectMake(0, buttonOriginY, LeftActionTabPageButtonWidth, LeftActionTabPageButtonHeight);
    
    deleteButton = [[UIButton alloc] initWithFrame:buttonFrame];
    deleteButton.backgroundColor = [UIColor orangeColor];
    [self addSubview:deleteButton];
}

-(void)setHeight:(CGFloat)height {
    self.frame = CGRectSetHeightForRect(height, self.frame);
    [self setNeedsLayout];
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    CGFloat buttonOriginY = self.frame.size.height / (numberOfButtons + 1) - LeftActionTabPageButtonHeight / 2;
    CGRect buttonFrame = CGRectMake(0, buttonOriginY, LeftActionTabPageButtonWidth, LeftActionTabPageButtonHeight);
    
    deleteButton.frame = buttonFrame;
}

#pragma mark PersonRowPageProtocol Functions

-(CGFloat)rightPageMargin {
    return 0;
}

@end
