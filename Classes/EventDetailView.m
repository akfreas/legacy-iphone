#import "EventDetailView.h"
#import "Event.h"
#import "AtYourAgeWebView.h"

@implementation EventDetailView {
    
    AtYourAgeWebView *webViewForEvent;

    IBOutlet UIView *eventDescriptionHostingView;
    IBOutlet UITextView *eventDescriptionTextView;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"EventDetailView" owner:self options:nil];
        [self addSubview:eventDescriptionHostingView];
    }
    return self;
}

-(void)layoutSubviews {
    eventDescriptionTextView.text = _event.eventDescription;
    [super layoutSubviews];
}

-(void)setEvent:(Event *)event {
    _event = event;
    [self setNeedsLayout];
}

@end
