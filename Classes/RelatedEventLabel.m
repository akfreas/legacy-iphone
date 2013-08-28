#import "RelatedEventLabel.h"
#import "Event.h"

@implementation RelatedEventLabel {
    
    
    IBOutlet UITextView *textView;
    IBOutlet UILabel *ageLabel;
    IBOutlet UIView *view;
}

-(id)initWithRelatedEvent:(Event *)anEvent {
    
    self = [super init];
    
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"RelatedEventLabel" owner:self options:nil];
        _event = anEvent;
        ageLabel.text = [NSString stringWithFormat:@"@ %@ years, %@ months, %@ days old ", _event.ageYears, _event.ageMonths, _event.ageDays];
        textView.text = _event.eventDescription;
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
