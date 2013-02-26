#import "AgeIndicatorView.h"
#import "Event.h"

@implementation AgeIndicatorView {
    
    IBOutlet UILabel *yearLabel;
    IBOutlet UILabel *monthLabel;
    IBOutlet UILabel *dayLabel;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"AgeIndicatorView" owner:self options:nil];
        [self addSubview:_view];
    }
    return self;
}

-(void)configureView {
    yearLabel.text = _event.ageYears;
    monthLabel.text = _event.ageMonths;
    dayLabel.text = _event.ageDays;
}

-(void)setEvent:(Event *)event {
    _event = event;
    [self configureView];
}

@end
