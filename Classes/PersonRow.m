#import "PersonRow.h"
#import "ImageWidgetContainer.h"
#import "PersonInfoView.h"
#import "Person.h"
#import "Event.h"
#import "AtYourAgeConnection.h"
#import "AtYourAgeRequest.h"


struct DualFrame {
    CGRect expanded;
    CGRect collapsed;
};

typedef struct DualFrame DualFrame;


@implementation PersonRow {
    
    //    IBOutlet UIView *view;
    IBOutlet UIButton *wikipediaButton;
    IBOutlet UIButton *trashcanButton;
    
    IBOutlet UIView *mainInfoHostingView;
    IBOutlet UITextView *eventDescriptionText;
    IBOutlet UILabel *figureNameLabel;
    IBOutlet UILabel *ageLabel;
    IBOutlet PersonInfoView *personInfo;
    IBOutlet ImageWidgetContainer *widgetContainer;

    AtYourAgeConnection *connection;

    
    DualFrame descriptionFrame;
    DualFrame widgetContainerFrame;
    DualFrame ageLabelFrame;
    DualFrame viewFrame;
    
}


+ (Class)layerClass {
    
    return [CAGradientLayer class];
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"PersonRow" owner:self options:nil];
        _expanded = NO;
        
        
        descriptionFrame.collapsed = eventDescriptionText.frame;
        descriptionFrame.expanded = CGRectMake(10, 185, 300, 60);
        widgetContainerFrame.collapsed = widgetContainer.frame;
        widgetContainerFrame.expanded = CGRectMake(self.frame.size.width / 2 - CGRectGetWidth(widgetContainer.frame) / 2 - 20, widgetContainer.frame.origin.y, CGRectGetWidth(widgetContainer.frame), CGRectGetHeight(widgetContainer.frame));
        ageLabelFrame.collapsed = ageLabel.frame;
        ageLabelFrame.expanded = CGRectMake(self.frame.size.width / 2 - CGRectGetWidth(ageLabel.frame) / 2, ageLabel.frame.origin.y, CGRectGetWidth(ageLabel.frame), CGRectGetHeight(ageLabel.frame));
        viewFrame.collapsed = _view.frame;
        viewFrame.expanded = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + 100);;
        
        [self addSubview:self.view];
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

-(void)toggleExpand {
    
    NSNumber *heightDifference;
    
    if (_expanded == NO) {
        [self expand];
        heightDifference = [NSNumber numberWithFloat:viewFrame.expanded.size.height - viewFrame.collapsed.size.height];
    } else {
        [self collapse];
        heightDifference = [NSNumber numberWithFloat:viewFrame.collapsed.size.height - viewFrame.expanded.size.height];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForPersonRowHeightChanged
                                                        object:self
                                                      userInfo:@{@"delta": heightDifference}];

}

-(void)expand {
    
    [UIView animateWithDuration:.2 animations:^{
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [widgetContainer expandWidget];
        self.view.layer.frame = viewFrame.expanded;
        eventDescriptionText.layer.frame = descriptionFrame.expanded;
        widgetContainer.layer.frame = widgetContainerFrame.expanded;
        ageLabel.frame = ageLabelFrame.expanded;
        [CATransaction commit];
        _expanded = YES;
        eventDescriptionText.frame = descriptionFrame.expanded;
        
        AtYourAgeRequest *request = [AtYourAgeRequest requestToGetRelatedEventsForEvent:_event.eventId requester:_person];
        
        connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
        
        [connection getWithCompletionBlock:^(AtYourAgeRequest *request, id result, NSError *error) {
            NSLog(@"Result: %@", result);
        }];
    }];
    
}

-(void)collapse {
    
    
    [UIView animateWithDuration:.2 animations:^{
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.2];
        [widgetContainer collapseWidget];
        self.view.layer.frame = viewFrame.collapsed;
        eventDescriptionText.layer.frame = descriptionFrame.collapsed;
        ageLabel.frame = ageLabelFrame.collapsed;
        widgetContainer.frame = widgetContainerFrame.collapsed;
        _expanded = NO;
        [CATransaction commit];
        eventDescriptionText.frame = descriptionFrame.collapsed;
    }];
}
@end
