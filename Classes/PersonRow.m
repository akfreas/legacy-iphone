#import "PersonRow.h"
#import "EventInfoView.h"
#import "PersonInfoView.h"
#import "EventDetailView.h"
#import "AgeIndicatorView.h"

@implementation PersonRow {
    
    IBOutlet UIView *view;
    IBOutlet UIButton *wikipediaButton;
    IBOutlet UIButton *trashcanButton;
    
    IBOutlet PersonInfoView *personInfo;
    IBOutlet EventInfoView *eventInfo;
    IBOutlet EventDetailView *eventDetail;
    IBOutlet AgeIndicatorView *ageIndicator;
    
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"PersonRow" owner:self options:nil];
        [self addSubview:view];
    }
    return self;
}

-(IBAction)wikipediaButtonAction:(id)sender {
    
    NSDictionary *userInfo = @{@"event": _event};
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForWikipediaButtonTappedNotification object:self userInfo:userInfo];
}

-(IBAction)trashcanButtonAction:(id)sender {
    
    NSDictionary *userInfo = @{@"person" : _person};
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForRemovePersonButtonTappedNotification object:self userInfo:userInfo];

}

-(void)setEvent:(Event *)event {
    _event = event;
    eventInfo.event = event;
    eventDetail.event = event;
    ageIndicator.event = event;
    [self layoutSubviews];
}

-(void)setPerson:(Person *)person {
    _person = person;
    personInfo.person = person;
    [self layoutSubviews];
}

@end
