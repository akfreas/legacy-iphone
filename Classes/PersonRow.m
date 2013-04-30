#import "PersonRow.h"
#import "ImageWidgetContainer.h"
#import "PersonInfoView.h"
#import "Person.h"
#import "Event.h"



@implementation PersonRow {
    
    IBOutlet UIView *view;
    IBOutlet UIButton *wikipediaButton;
    IBOutlet UIButton *trashcanButton;
    
    IBOutlet UIView *mainInfoHostingView;
    IBOutlet UITextView *eventDescriptionText;
    IBOutlet UILabel *figureNameLabel;
    IBOutlet UILabel *ageLabel;
    IBOutlet PersonInfoView *personInfo;
    IBOutlet ImageWidgetContainer *widgetContainer;
}


+ (Class)layerClass {
    
    return [CAGradientLayer class];
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
    
    [self postWikiNotif];
}

-(void)postWikiNotif {
    NSDictionary *userInfo = @{@"person" : _person};
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForRemovePersonButtonTappedNotification object:self userInfo:userInfo];

}

-(void)setEvent:(Event *)event {
    _event = event;
    figureNameLabel.text = event.figureName;
    widgetContainer.event = event;
    eventDescriptionText.text = event.eventDescription;
    ageLabel.text = [NSString stringWithFormat:@"@ %@ years, %@ months, %@ days old ", event.ageYears, event.ageMonths, event.ageDays];
    ageLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:.6];
    ageLabel.layer.cornerRadius = 10;
}

-(void)setPerson:(Person *)person {
    _person = person;
//    personInfo.person = person;
    widgetContainer.person = person;
    if ([_person.isPrimary isEqualToNumber: [NSNumber numberWithBool:NO]]) {
        trashcanButton.hidden = NO;
    }
}

@end
