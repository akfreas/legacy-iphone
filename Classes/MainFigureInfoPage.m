#import "MainFigureInfoPage.h"
#import "ImageWidgetContainer.h"
#import "Person.h"
#import "Event.h"
#import "RelatedEvent.h"
#import "AtYourAgeConnection.h"
#import "AtYourAgeRequest.h"
#import "RelatedEventLabel.h"
#import "ProgressIndicator.h"
#import "ImageWidget.h"
#import "RightIndicatorLines.h"


struct DualFrame {
    CGRect expanded;
    CGRect collapsed;
};

typedef struct DualFrame DualFrame;


@implementation MainFigureInfoPage {
    
    IBOutlet UIButton *wikipediaButton;
    IBOutlet UIButton *trashcanButton;
    
    IBOutlet UITextView *eventDescriptionText;
    IBOutlet UILabel *figureNameLabel;
    IBOutlet UILabel *ageLabel;

    AtYourAgeConnection *connection;
    ProgressIndicator *ind;
    RightIndicatorLines *indLines;

    DualFrame descriptionFrame;
    DualFrame widgetContainerFrame;
    DualFrame ageLabelFrame;
    DualFrame viewFrame;
    
    NSNumber *rowHeightDelta;
    NSMutableArray *arrayOfRelatedEventLabels;
    
    void(^publicExpandCompletion)(BOOL expanded);
    
    CGPoint selfEventRightmostPoint;
}


+ (Class)layerClass {
    return [CAGradientLayer class];
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"MainFigureInfoPage" owner:self options:nil];
        _expanded = NO;
        
        
        descriptionFrame.collapsed = eventDescriptionText.frame;
        descriptionFrame.expanded = CGRectMake(10, 185, 300, 60);
        widgetContainerFrame.collapsed = self.widgetContainer.frame;
        widgetContainerFrame.expanded = CGRectMake(self.frame.size.width / 2 - CGRectGetWidth(self.widgetContainer.frame), self.widgetContainer.frame.origin.y, CGRectGetWidth(self.widgetContainer.frame) + 50, CGRectGetHeight(self.widgetContainer.frame) + 50);
        ageLabelFrame.collapsed = ageLabel.frame;
        ageLabelFrame.expanded = CGRectMake(self.frame.size.width / 2 - CGRectGetWidth(ageLabel.frame) / 2, ageLabel.frame.origin.y, CGRectGetWidth(ageLabel.frame), CGRectGetHeight(ageLabel.frame));
        viewFrame.collapsed = _view.frame;
        viewFrame.expanded = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + 60);
        arrayOfRelatedEventLabels = [NSMutableArray array];
        [self addSubview:self.view];
        CGPoint widgetPoint = [self.view convertPoint:self.widgetContainer.widget.largeImageFrame.origin fromView:self.widgetContainer.widget];
        widgetPoint = CGPointMake(widgetPoint.x + self.widgetContainer.widget.largeImageRadius, widgetPoint.y + self.widgetContainer.widget.largeImageRadius);
        ind = [[ProgressIndicator alloc] initWithCenterPoint:widgetPoint radius:self.widgetContainer.widget.largeImageRadius];
  
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventLoadingComplete:) name:KeyForEventLoadingComplete object:self.widgetContainer];
        [self.layer addSublayer:ind];
        
        self.scrollEnabled = NO;
        
    }
    return self;
}


-(IBAction)wikipediaButtonAction:(id)sender {
    
    NSDictionary *userInfo = @{@"event": self.event};
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForWikipediaButtonTappedNotification object:self userInfo:userInfo];
}

-(IBAction)trashcanButtonAction:(id)sender {
    
    [self postWikiNotif];
}


-(void)showActivityMonitor {
    ageLabel.hidden = YES;
    figureNameLabel.hidden = YES;
    self.widgetContainer.hidden = YES;
    
}

-(void)hideActivityMonitor {
    
}

-(void)postWikiNotif {
    NSDictionary *userInfo = @{@"person" : _person};
    [[NSNotificationCenter defaultCenter] postNotificationName:KeyForRemovePersonButtonTappedNotification object:self userInfo:userInfo];
    
}

-(void)setEvent:(Event *)event {
//    [ind animate];
    _event = event;
    figureNameLabel.text = event.figureName;
    self.widgetContainer.event = event;
    eventDescriptionText.text = event.eventDescription;
    ageLabel.text = [NSString stringWithFormat:@"@ %@ years, %@ months, %@ days old ", event.ageYears, event.ageMonths, event.ageDays];
    ageLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:.6];
    ageLabel.layer.cornerRadius = 10;
}

-(void)eventLoadingComplete:(NSNotification *)notif {
    [ind stopAnimating];
    [ind removeFromSuperlayer];
}

-(void)setPerson:(Person *)person {
    _person = person;
    //    personInfo.person = person;
    self.widgetContainer.person = person;
    if ([_person.isPrimary isEqualToNumber: [NSNumber numberWithBool:NO]]) {
        trashcanButton.hidden = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [ind animate];
    });
}

-(void)recordHeightDelta:(NSNotification *)notification {
    
    CGFloat theDelta = [[notification.userInfo objectForKey:@"delta"] floatValue];
    
    if (theDelta > 0) {
        rowHeightDelta = [NSNumber numberWithFloat:[rowHeightDelta floatValue] + theDelta];
    } else {
        rowHeightDelta = [NSNumber numberWithFloat:0];
    }
}

-(void)toggleExpandWithCompletion:(void(^)(BOOL expanded))completion {

    publicExpandCompletion = completion;
    if (_expanded == NO) {
        [self expandWithCompletion:[self expandCompletionBlock]];
    } else {
        [self collapseWithCompletionBlock:[self collapseCompletionBlock]];
    }
}

-(void(^)(void))collapseCompletionBlock {
    return ^{
        
        NSNumber *heightDifference = [NSNumber numberWithFloat: -1 * [rowHeightDelta floatValue]];
        NSLog(@"Height delta in collapse completion block: %@", rowHeightDelta);

        rowHeightDelta = [NSNumber numberWithFloat:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForPersonRowHeightChanged
                                                            object:self
                                                          userInfo:@{@"delta": heightDifference}];
        publicExpandCompletion(NO);
    };
}


-(void(^)(NSNumber *))expandCompletionBlock {
    return ^(NSNumber *delta){
        
        rowHeightDelta = [NSNumber numberWithFloat:[rowHeightDelta floatValue] + [delta floatValue]];
        NSLog(@"Height delta in expand completion block: %@", rowHeightDelta);

        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForPersonRowHeightChanged
                                                            object:self
                                                          userInfo:@{@"delta": delta}];
        publicExpandCompletion(YES);
    };
}


-(void)getRelatedEventsAndExpandWithCompletion:(void(^)(NSNumber *heightIncrease))completionBlock {
    
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetRelatedEventsForEvent:self.event.eventId requester:_person];
    CGFloat labelHeight = 54;
    CGFloat labelWidth = 300;
    connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, NSDictionary *eventDict, NSError *error) {
        
        NSArray *eventResult = [eventDict objectForKey:@"events"];
        NSLog(@"Events: %@", eventResult);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (int i=0; i < eventResult.count; i++) {
                
                RelatedEvent *relatedEvent = [[RelatedEvent alloc] initWithJsonDictionary:[eventResult objectAtIndex:i]];
                
                __block RelatedEventLabel *eventLabel = [[RelatedEventLabel alloc] initWithRelatedEvent:relatedEvent];
                eventLabel.alpha = 0;
                eventLabel.frame = CGRectMake(0, self.view.frame.size.height + labelHeight * i, labelWidth, labelHeight);
                
                if (relatedEvent.isSelf == YES) {
                    selfEventRightmostPoint = CGPointMake(CGRectGetMaxX(eventLabel.frame), CGRectGetMaxY(eventLabel.frame) - CGRectGetHeight(eventLabel.frame) / 2);
//                    eventLabel.backgroundColor = [UIColor lightGrayColor];
                    eventLabel.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:.2].CGColor;
                    eventLabel.layer.cornerRadius = 15.0;
                }
                
                [self.view addSubview:eventLabel];
                [arrayOfRelatedEventLabels addObject:eventLabel];
            }
            __block NSNumber *heightDelta;
            CGFloat heightIncrease = labelHeight * [eventResult count];
            heightDelta = [NSNumber numberWithFloat:heightIncrease + viewFrame.expanded.size.height - viewFrame.collapsed.size.height];
            completionBlock(heightDelta);

            [UIView animateWithDuration:0.2 animations:^{
                
                self.view.layer.frame = CGRectMake(self.view.layer.frame.origin.x, self.view.layer.frame.origin.y, self.view.layer.frame.size.width, self.view.layer.frame.size.height + heightIncrease);
                self.frame = CGRectMake(self.view.layer.frame.origin.x, self.view.layer.frame.origin.y, self.view.layer.frame.size.width, MIN(self.view.layer.frame.size.height + heightIncrease, 416));
                self.contentSize = self.view.frame.size;
                
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    
                    for (UILabel *theLabel in arrayOfRelatedEventLabels) {
                        theLabel.alpha = 1;
                    }
                    [self addIndicatorLines];

                }];
            }];
        });
    }];
}


-(void)addIndicatorLines {

    
    CGRect largeImageRect = self.widgetContainer.frame   ;
    
    CGPoint startPoint = CGPointMake(largeImageRect.origin.x + largeImageRect.size.width, largeImageRect.origin.y + largeImageRect.size.height / 2);
    CGPoint translatedEndPoint = CGPointMake(selfEventRightmostPoint.x - startPoint.x, selfEventRightmostPoint.y - startPoint.y);
    indLines = [[RightIndicatorLines alloc] initWithStartPoint:startPoint endPoint:translatedEndPoint];
    indLines.person = self.person;
    [self addSubview:indLines];
}

-(void)removeIndicatorLines {
    [indLines removeFromSuperview];
}

-(void)expandWithCompletion:(void(^)(NSNumber *))completionBlock {
    
    [UIView animateWithDuration:.2 animations:^{

        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [self.widgetContainer expandWidget];
        self.view.frame = self.frame = viewFrame.expanded;
        eventDescriptionText.layer.frame = descriptionFrame.expanded;
        eventDescriptionText.layer.opacity = 0;
        self.widgetContainer.layer.frame = widgetContainerFrame.expanded;
        ageLabel.frame = ageLabelFrame.expanded;
        ageLabel.layer.opacity = 0;

        [CATransaction commit];
        _expanded = YES;
        eventDescriptionText.frame = descriptionFrame.expanded;
        [self getRelatedEventsAndExpandWithCompletion:completionBlock];
        self.scrollEnabled = YES;
    }];
    
}

-(void)collapseWithCompletionBlock:(void(^)(void))completionBlock {
    
    
    [UIView animateWithDuration:.2 animations:^{
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.2];
        [self removeIndicatorLines];
        [self.widgetContainer collapseWidget];
        self.view.layer.frame = viewFrame.collapsed;
        eventDescriptionText.layer.frame = descriptionFrame.collapsed;
        eventDescriptionText.layer.opacity = 1;
        ageLabel.frame = ageLabelFrame.collapsed;
        ageLabel.layer.opacity = 1;
        self.widgetContainer.frame = widgetContainerFrame.collapsed;
        _expanded = NO;
        [CATransaction commit];
        eventDescriptionText.frame = descriptionFrame.collapsed;
        
        for (UILabel *relatedEventLabel in arrayOfRelatedEventLabels) {
            [relatedEventLabel removeFromSuperview];
        }
        self.scrollEnabled = NO;
        
        completionBlock();
        
    }];
}
@end
