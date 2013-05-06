#import "PersonRow.h"
#import "ImageWidgetContainer.h"
#import "PersonInfoView.h"
#import "Person.h"
#import "Event.h"


struct DualFrame {
    CGRect expanded;
    CGRect collapsed;
};

typedef struct DualFrame DualFrame;


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
    
    
    BOOL expanded;
    
    
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
        expanded = NO;
        
        
        descriptionFrame.collapsed = eventDescriptionText.frame;
        descriptionFrame.expanded = CGRectMake(10, 185, 300, 60);
        widgetContainerFrame.collapsed = widgetContainer.frame;
        widgetContainerFrame.expanded = CGRectMake(self.frame.size.width / 2 - CGRectGetWidth(widgetContainer.frame) / 2 - 20, widgetContainer.frame.origin.y, CGRectGetWidth(widgetContainer.frame), CGRectGetHeight(widgetContainer.frame));
        ageLabelFrame.collapsed = ageLabel.frame;
        ageLabelFrame.expanded = CGRectMake(self.frame.size.width / 2 - CGRectGetWidth(ageLabel.frame) / 2, ageLabel.frame.origin.y, CGRectGetWidth(ageLabel.frame), CGRectGetHeight(ageLabel.frame));
        viewFrame.collapsed = view.frame;
        viewFrame.expanded = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height + 100);;
        
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


-(void)expandRow {
    
    if (expanded == NO) {

//        [UIView beginAnimations:nil context:NULL];
        [UIView animateWithDuration:.2 animations:^{
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:0];
            [widgetContainer expandWidget];
            view.layer.frame = viewFrame.expanded;
//            widgetContainer.backgroundColor = [UIColor greenColor];
            eventDescriptionText.layer.frame = descriptionFrame.expanded;
//            view.layer.backgroundColor = [UIColor redColor].CGColor;
//            eventDescriptionText.layer.backgroundColor = [UIColor orangeColor].CGColor;
            widgetContainer.layer.frame = widgetContainerFrame.expanded;
            ageLabel.frame = ageLabelFrame.expanded;
            [CATransaction commit];
            expanded = YES;
            eventDescriptionText.frame = descriptionFrame.expanded;
        }];
//        [UIView commitAnimations];

    } else {

        [UIView animateWithDuration:.2 animations:^{
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:.2];
            [widgetContainer collapseWidget];
            view.layer.frame = viewFrame.collapsed;
            eventDescriptionText.layer.frame = descriptionFrame.collapsed;
            ageLabel.frame = ageLabelFrame.collapsed;
            widgetContainer.frame = widgetContainerFrame.collapsed;
            expanded = NO;
            [CATransaction commit];
            eventDescriptionText.frame = descriptionFrame.collapsed;
        }];
    }
}

@end
