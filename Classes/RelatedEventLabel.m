#import "RelatedEventLabel.h"
#import "Event.h"

@implementation RelatedEventLabel {
    
    Event *relatedEvent;
    
    IBOutlet UITextView *textView;
    IBOutlet UILabel *ageLabel;
    IBOutlet UIView *view;
}

-(id)initWithRelatedEvent:(Event *)event {
    
    self = [super init];
    
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"RelatedEventLabel" owner:self options:nil];
        relatedEvent = event;
        ageLabel.text = [NSString stringWithFormat:@"@ %@ years, %@ months, %@ days old ", event.ageYears, event.ageMonths, event.ageDays];
        textView.text = relatedEvent.eventDescription;
        [self addSubview:view];
    }
    return self;
}

-(void)setAlpha:(CGFloat)alpha {
    textView.alpha = alpha;
    ageLabel.alpha = alpha;
    view.alpha = alpha;
}

@end
