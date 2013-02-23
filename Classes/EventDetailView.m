#import "EventDetailView.h"
#import "Event.h"
#import "YardstickWebView.h"

@implementation EventDetailView {
    
    YardstickWebView *webViewForEvent;

    IBOutlet UIView *eventDescriptionHostingView;
    IBOutlet UITextView *eventDescriptionTextView;
    
    IBOutlet UIButton *buttonPlaceHolder;
    IBOutlet UIButton *wikipediaButton;
}

-(id)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"EventDetailView" owner:self options:nil];
        [self addSubview:eventDescriptionHostingView];
//        wikipediaButton.frame = buttonPlaceHolder.frame;
        [self addSubview:wikipediaButton];
        [buttonPlaceHolder removeFromSuperview];
        wikipediaButton.userInteractionEnabled = YES;
    }
    return self;
}


-(IBAction)wikipediaButtonAction:(id)sender {
//    self.wikipediaButtonTappedActionBlock(_event);
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
