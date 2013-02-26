#import "PersonRow.h"
#import "EventInfoView.h"
#import "PersonInfoView.h"
#import "EventDetailView.h"
#import "AgeIndicatorView.h"
#import "Person.h"

@implementation PersonRow {
    
    IBOutlet UIView *view;
    IBOutlet UIButton *wikipediaButton;
    IBOutlet UIButton *trashcanButton;
    
    IBOutlet UIView *mainInfoHostingView;
    IBOutlet PersonInfoView *personInfo;
    IBOutlet EventInfoView *eventInfo;
    IBOutlet EventDetailView *eventDetail;    
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"PersonRow" owner:self options:nil];
        [self addSubview:view];
        mainInfoHostingView.backgroundColor = [UIColor colorWithWhite:1 alpha:.4];
        
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
    _ageIndicator.event = event;
}

-(void)setPerson:(Person *)person {
    _person = person;
    personInfo.person = person;
    if ([_person.isPrimary isEqualToNumber: [NSNumber numberWithBool:NO]]) {
        trashcanButton.hidden = NO;
    }
}

@end
