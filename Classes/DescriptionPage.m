#import "DescriptionPage.h"
#import "Figure.h"

@implementation DescriptionPage {
    
    Figure *figure;
    
    IBOutlet UITextView *descriptionText;
}

- (id)initWithFigure:(Figure *)theFigure {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 200)];
    if (self) {
        figure = theFigure;
        [[NSBundle mainBundle] loadNibNamed:@"DescriptionPage" owner:self options:nil];
        self.backgroundColor = [UIColor redColor];
        [self addSubview:self.view];
        descriptionText.text = figure.description;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{

}


@end
