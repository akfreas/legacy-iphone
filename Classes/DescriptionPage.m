#import "DescriptionPage.h"
#import "Figure.h"

@implementation DescriptionPage {
    
    Figure *figure;
    
    IBOutlet UITextView *descriptionText;
}

- (id)initWithFigure:(Figure *)theFigure {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        figure = theFigure;
        [[NSBundle mainBundle] loadNibNamed:@"DescriptionPage" owner:self options:nil];
        [self addSubview:self.view];
        descriptionText.text = figure.description;
        descriptionText.editable = NO;
    }
    return self;
}

-(CGFloat)rightPageMargin {
    return SpaceBetweenPersonRowPages;
}

@end
