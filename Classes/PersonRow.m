#import "PersonRow.h"
#import "ImageWidgetContainer.h"
#import "PersonInfoView.h"
#import "Person.h"
#import "Event.h"
#import "RelatedEvent.h"
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
    
    NSNumber *rowHeightDelta;
    NSMutableArray *arrayOfRelatedEventLabels;
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
        viewFrame.expanded = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + 100);
        arrayOfRelatedEventLabels = [NSMutableArray array];
        [self addSubview:self.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordHeightDelta:) name:KeyForPersonRowHeightChanged object:nil];
        
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

-(void)recordHeightDelta:(NSNotification *)notification {
    
    CGFloat theDelta = [[notification.userInfo objectForKey:@"delta"] floatValue];
    
    if (theDelta > 0) {
        rowHeightDelta = [NSNumber numberWithFloat:[rowHeightDelta floatValue] + theDelta];
    } else {
        rowHeightDelta = [NSNumber numberWithFloat:0];
    }
}

-(void)toggleExpand {
    
    NSNumber *heightDifference;
    
    if (_expanded == NO) {
        [self expandWithCompletion:[self expandCompletionBlock]];
    } else {
        [self collapseWithCompletionBlock:[self collapseCompletionBlock]];
    }
}

-(void(^)(void))collapseCompletionBlock {
    return ^{
        NSNumber *heightDifference = [NSNumber numberWithFloat:viewFrame.expanded.size.height - viewFrame.collapsed.size.height];
        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForPersonRowHeightChanged
                                                            object:self
                                                          userInfo:@{@"delta": heightDifference}];
    };
}


-(void(^)(void))expandCompletionBlock {
    return ^{
        NSNumber *heightDifference = [NSNumber numberWithFloat: -1 * [rowHeightDelta floatValue]];
//        rowHeightDelta = [NSNumber numberWithFloat:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForPersonRowHeightChanged
                                                            object:self
                                                          userInfo:@{@"delta": heightDifference}];
    };
}

-(void)getRelatedEventsAndExpandWithCompletion:(void(^)(void))completionBlock {
    
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetRelatedEventsForEvent:_event.eventId requester:_person];
    CGFloat labelHeight = 50;
    CGFloat labelWidth = 300;
    connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, NSDictionary *eventDict, NSError *error) {
        
        NSArray *eventResult = [eventDict objectForKey:@"events"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (int i=0; i < eventResult.count; i++) {
                
                RelatedEvent *relatedEvent = [[RelatedEvent alloc] initWithJsonDictionary:[eventResult objectAtIndex:i]];
                UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height + labelHeight * i, labelWidth, labelHeight)];
                eventLabel.layer.opacity = 0;
                eventLabel.text = relatedEvent.eventDescription;
                [self.view addSubview:eventLabel];
                [arrayOfRelatedEventLabels addObject:eventLabel];
            }
            [UIView animateWithDuration:0.2 animations:^{
                
                CGFloat heightIncrease = labelHeight * [eventResult count];
                self.view.layer.frame = CGRectMake(self.view.layer.frame.origin.x, self.view.layer.frame.origin.x, self.view.layer.frame.size.width, self.view.layer.frame.size.height + heightIncrease);
                NSNumber *heightDelta = [NSNumber numberWithFloat:heightIncrease];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KeyForPersonRowHeightChanged
                                                                    object:self
                                                                  userInfo:@{@"delta": heightDelta}];
            } completion:^(BOOL finished) {
                for (UILabel *theLabel in arrayOfRelatedEventLabels) {
                    theLabel.layer.opacity = 1;
                }
                completionBlock();
            }];
        });
    }];
}

-(void)expandWithCompletion:(void(^)(void))completionBlock {
    
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

    } completion:^(BOOL finished) {
        [self getRelatedEventsAndExpandWithCompletion:completionBlock];
    }];
    
}

-(void)collapseWithCompletionBlock:(void(^)(void))completionBlock {
    
    
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
        
        for (UILabel *relatedEventLabel in arrayOfRelatedEventLabels) {
            [relatedEventLabel removeFromSuperview];
        }
        
    } completion:^(BOOL finished) {
        completionBlock();
    }];
}
@end
