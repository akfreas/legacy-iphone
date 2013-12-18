#import "FigureRowContentView.h"
#import "ImageWidgetContainer.h"
#import "Person.h"
#import "Event.h"
#import "Figure.h"
#import "LegacyAppConnection.h"
#import "LegacyAppRequest.h"
#import "RelatedEventLabel.h"
#import "ImageWidget.h"
#import "Utility_AppSettings.h"

@implementation FigureRowContentView {
    
    IBOutlet UITextView *eventDescriptionText;
    IBOutlet UILabel *figureNameLabel;
    IBOutlet UILabel *ageLabel;

    LegacyAppConnection *connection;
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
        [[NSBundle mainBundle] loadNibNamed:@"FigureRowContentView" owner:self options:nil];
        [self addSubview:self.view];
        self.scrollEnabled = NO;
    }
    return self;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    self.view.backgroundColor = backgroundColor;
}

-(void)setEvent:(Event *)event {
    _event = event;
    figureNameLabel.text = event.figure.name;
    self.widgetContainer.event = event;
    eventDescriptionText.text = event.eventDescription;
    ageLabel.text = [NSString stringWithFormat:@"@ %@ years, %@ months, %@ days old ", event.ageYears, event.ageMonths, event.ageDays];
    figureNameLabel.font = [UIFont fontWithName:@"Cinzel-Regular" size:20.0f];
    ageLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:.6];
    ageLabel.layer.cornerRadius = 10;
}
-(void)setPerson:(Person *)person {
    _person = person;
    self.widgetContainer.person = person;
}
@end
