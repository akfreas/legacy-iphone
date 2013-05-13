#import "EventDescriptionView.h"
#import "Event.h"
#import "AtYourAgeWebView.h"

@implementation EventDescriptionView {
    
    AtYourAgeWebView *webViewForEvent;

    IBOutlet UIView *eventDescriptionHostingView;
    IBOutlet UITextView *eventDescriptionTextView;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"EventDescriptionView" owner:self options:nil];
        [self addSubview:eventDescriptionHostingView];
    }
    return self;
}

-(void)layoutSubviews {
    eventDescriptionTextView.text = _event.eventDescription;
    [super setNeedsLayout];
}

-(void)setEvent:(Event *)event {
    _event = event;
    [self setNeedsLayout];
}

@end
