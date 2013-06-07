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
#import "Utility_AppSettings.h"

typedef struct DualFrame {
    CGRect expanded;
    CGRect collapsed;
    CGFloat (* heightDelta)();
} DualFrame;

CGFloat heightDelta(DualFrame *mine) {
    CGFloat d = mine->expanded.size.height - mine->collapsed.size.height;
    return d;
}

DualFrame * initFrame() {
    DualFrame *df = (DualFrame*)malloc(sizeof(DualFrame));
    df->heightDelta = &heightDelta;
    return df;
}
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
        [self setUpFrames];
        _expanded = NO;

        arrayOfRelatedEventLabels = [NSMutableArray array];
        [self addSubview:self.view];
        CGPoint widgetPoint = [self.view convertPoint:self.widgetContainer.widget.largeImageFrame.origin fromView:self.widgetContainer.widget];
        widgetPoint = CGPointMake(widgetPoint.x + self.widgetContainer.widget.largeImageRadius, widgetPoint.y + self.widgetContainer.widget.largeImageRadius);
        ind = [[ProgressIndicator alloc] initWithCenterPoint:widgetPoint radius:self.widgetContainer.widget.largeImageRadius];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventLoadingComplete:) name:KeyForEventLoadingComplete object:self.widgetContainer];
        [self.layer addSublayer:ind];
//        self.contentSize = CGSizeMakeFromRect(viewFrame.collapsed);
        [self setContentFrames:viewFrame.collapsed];
        self.scrollEnabled = NO;
        
    }
    return self;
}

-(void)setUpFrames {
    
    descriptionFrame.collapsed = eventDescriptionText.frame;
    descriptionFrame.expanded = CGRectMake(EventDescriptionX, EventDescriptionY, EventDescriptionWidth, EventDescriptionHeight);
    
    widgetContainerFrame.collapsed = self.widgetContainer.frame;
    widgetContainerFrame.expanded = CGRectMake(self.frame.size.width / 2 - ImageWidgetExpandTransformFactor / 2 * ImageWidgetInitialWidth + ImageLayerDefaultStrokeWidth * 2, widgetContainerFrame.collapsed.origin.y, CGRectGetWidth(widgetContainerFrame.collapsed) + ImageWidgetExpandTransformFactor * ImageWidgetInitialWidth - CGRectGetWidth(widgetContainerFrame.collapsed) + ImageLayerDefaultStrokeWidth * 2, CGRectGetHeight(widgetContainerFrame.collapsed) + ImageWidgetExpandTransformFactor * ImageWidgetInitialHeight - CGRectGetHeight(widgetContainerFrame.collapsed) + ImageLayerDefaultStrokeWidth * 2);
    
    ageLabelFrame.collapsed = ageLabel.frame;
    ageLabelFrame.expanded = CGRectMake(self.frame.size.width / 2 - CGRectGetWidth(ageLabel.frame) / 2, ageLabel.frame.origin.y, CGRectGetWidth(ageLabel.frame), CGRectGetHeight(ageLabel.frame));
    
    viewFrame.collapsed = _view.frame;
    viewFrame.expanded = CGRectMake(viewFrame.collapsed.origin.x, viewFrame.collapsed.origin.y, viewFrame.collapsed.size.width, viewFrame.collapsed.size.height + widgetContainerFrame.expanded.size.height - widgetContainerFrame.collapsed.size.height + RelatedEventsLabelTopMargin);//ImageWidgetInitialHeight * ImageWidgetExpandTransformFactor);
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
    connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, NSDictionary *eventDict, NSError *error) {
        
        NSArray *eventResult = [eventDict objectForKey:@"events"];
        NSLog(@"Events: %@", eventResult);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (int i=0; i < eventResult.count; i++) {
                
                RelatedEvent *relatedEvent = [[RelatedEvent alloc] initWithJsonDictionary:[eventResult objectAtIndex:i]];
                
                __block RelatedEventLabel *eventLabel = [[RelatedEventLabel alloc] initWithRelatedEvent:relatedEvent];
                eventLabel.alpha = 0;
                eventLabel.frame = CGRectMake(0, viewFrame.expanded.size.height + RelatedEventsLabelHeight * i, RelatedEventsLabelWidth, RelatedEventsLabelHeight);
                
                if (relatedEvent.isSelf == YES) {
                    selfEventRightmostPoint = CGPointMake(CGRectGetMaxX(eventLabel.frame), CGRectGetMaxY(eventLabel.frame) - CGRectGetHeight(eventLabel.frame) / 2);
                    eventLabel.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:.2].CGColor;
                    eventLabel.layer.cornerRadius = 15.0;
                }
                
                [self.view addSubview:eventLabel];
                [arrayOfRelatedEventLabels addObject:eventLabel];
            }
            CGFloat contentSizeIncrease = RelatedEventsLabelHeight * [eventResult count] + viewFrame.expanded.size.height - viewFrame.collapsed.size.height;
            CGFloat frameDelta;
            CGRect keyWindowFrame = Utility_AppSettings.frameForKeyWindow;
            CGFloat availableHeight = keyWindowFrame.size.height - MoreCloseButtonHeight - 20 - 44;
            if (contentSizeIncrease + viewFrame.expanded.size.height > availableHeight) {
                frameDelta = availableHeight - viewFrame.collapsed.size.height;
            } else {
                frameDelta = contentSizeIncrease;
            }
            
            CGRect newContentRect = CGRectAddHeightToRect(self.view.frame, contentSizeIncrease);
            CGRect newFrameRect = CGRectAddHeightToRect(viewFrame.collapsed, frameDelta);
            [self setContentFrames:newContentRect];

            [UIView animateWithDuration:0.2 animations:^{
                
                self.frame =  newFrameRect;
            __block NSNumber *frameDeltaNumber;
            frameDeltaNumber = [NSNumber numberWithFloat:frameDelta];
            completionBlock(frameDeltaNumber);
                
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

    
    CGRect largeImageRect = self.widgetContainer.frame;
    CGPoint startPoint = CGPointMake(largeImageRect.origin.x + largeImageRect.size.width, largeImageRect.origin.y + largeImageRect.size.height / 2);
    CGPoint translatedEndPoint = CGPointMake(selfEventRightmostPoint.x - startPoint.x, selfEventRightmostPoint.y - startPoint.y);
    indLines = [[RightIndicatorLines alloc] initWithStartPoint:startPoint endPoint:translatedEndPoint];
    indLines.person = self.person;
    [self addSubview:indLines];
}

-(void)removeIndicatorLines {
    [indLines removeFromSuperview];
}

-(void)setContentFrames:(CGRect)rect {
    self.view.frame = rect;
    self.contentSize = CGSizeMakeFromRect(rect);
}

-(void)expandWithCompletion:(void(^)(NSNumber *))completionBlock {
    
    [UIView animateWithDuration:.2 animations:^{

        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [self.widgetContainer expandWidget];
        eventDescriptionText.layer.frame = descriptionFrame.expanded;
        eventDescriptionText.layer.opacity = 0;
        self.widgetContainer.frame = widgetContainerFrame.expanded;
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
        [self setContentFrames:viewFrame.collapsed];
        self.frame = viewFrame.collapsed;
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
