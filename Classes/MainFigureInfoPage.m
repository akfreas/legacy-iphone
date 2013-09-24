#import "MainFigureInfoPage.h"
#import "ImageWidgetContainer.h"
#import "Person.h"
#import "Event.h"
#import "Figure.h"
#import "LegacyAppConnection.h"
#import "LegacyAppRequest.h"
#import "RelatedEventLabel.h"
#import "ImageWidget.h"
#import "RightIndicatorLines.h"
#import "Utility_AppSettings.h"

typedef struct DualFrame {
    CGRect expanded;
    CGRect collapsed;
    CGFloat (* heightDelta)();
} DualFrame;

CGFloat heightDelta(DualFrame *mine) {
    CGFloat d = mine->expanded.size.height - mine->collapsed.size.height;
    return d;
}

DualFrame * initFrame() {
    DualFrame *df = (DualFrame*)malloc(sizeof(DualFrame));
    df->heightDelta = &heightDelta;
    return df;
}


@implementation MainFigureInfoPage {
    
    IBOutlet UIButton *wikipediaButton;
    IBOutlet UIButton *trashcanButton;
    
    IBOutlet UITextView *eventDescriptionText;
    IBOutlet UILabel *figureNameLabel;
    IBOutlet UILabel *ageLabel;

    LegacyAppConnection *connection;
    RightIndicatorLines *indLines;

    DualFrame descriptionFrame;
    DualFrame widgetContainerFrame;
    DualFrame ageLabelFrame;
    DualFrame viewFrame;
    
    NSNumber *rowHeightDelta;
    NSMutableArray *arrayOfRelatedEventLabels;
    NSArray *relatedEventArray;
    
    void(^publicExpandCompletion)(BOOL expanded);
    
    CGPoint selfEventRightmostPoint;
}


+ (Class)layerClass {
    return [CAGradientLayer class];
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"MainFigureInfoPage" owner:self options:nil];
        [self addSubview:self.view];
//        ind.frame = CGRectMakeFrameForDeadCenterInRect(self.widgetContainer.bounds, CGSizeMake(self.widgetContainer.widget.largeImageRadius, self.widgetContainer.widget.largeImageRadius));
        
        self.scrollEnabled = NO;
    }
    return self;
}

-(void)setEvent:(Event *)event {
    _event = event;
    figureNameLabel.text = event.figure.name;
    self.widgetContainer.event = event;
    eventDescriptionText.text = event.eventDescription;
    ageLabel.text = [NSString stringWithFormat:@"@ %@ years, %@ months, %@ days old ", event.ageYears, event.ageMonths, event.ageDays];
    ageLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:.6];
    ageLabel.layer.cornerRadius = 10;
}
-(void)setPerson:(Person *)person {
    _person = person;
    //    personInfo.person = person;
    self.widgetContainer.person = person;
}
@end
