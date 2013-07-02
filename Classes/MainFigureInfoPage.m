#import "MainFigureInfoPage.h"
#import "ImageWidgetContainer.h"
#import "Person.h"
#import "Event.h"
#import "Figure.h"
#import "RelatedEvent.h"
#import "AtYourAgeConnection.h"
#import "AtYourAgeRequest.h"
#import "RelatedEventLabel.h"
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


@implementation MainFigureInfoPage {
    
    IBOutlet UIButton *wikipediaButton;
    IBOutlet UIButton *trashcanButton;
    
    IBOutlet UITextView *eventDescriptionText;
    IBOutlet UILabel *figureNameLabel;
    IBOutlet UILabel *ageLabel;

    AtYourAgeConnection *connection;
    RightIndicatorLines *indLines;

    DualFrame descriptionFrame;
    DualFrame widgetContainerFrame;
    DualFrame ageLabelFrame;
    DualFrame viewFrame;
    
    NSNumber *rowHeightDelta;
    NSMutableArray *arrayOfRelatedEventLabels;
    NSArray *relatedEventArray;
    
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
//        ind.frame = CGRectMakeFrameForDeadCenterInRect(self.widgetContainer.bounds, CGSizeMake(self.widgetContainer.widget.largeImageRadius, self.widgetContainer.widget.largeImageRadius));
        
        self.scrollEnabled = NO;
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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


    

-(void)setEvent:(Event *)event {
    _event = event;
    figureNameLabel.text = event.figure.name;
    self.widgetContainer.event = event;
    eventDescriptionText.text = event.eventDescription;
    ageLabel.text = [NSString stringWithFormat:@"@ %@ years, %@ months, %@ days old ", event.ageYears, event.ageMonths, event.ageDays];
    ageLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:.6];
    ageLabel.layer.cornerRadius = 10;
}

-(void)eventLoadingComplete:(NSNotification *)notif {
//    [ind stopAnimating];
//    [ind removeFromSuperlayer];
}

-(void)setPerson:(Person *)person {
    _person = person;
    //    personInfo.person = person;
    self.widgetContainer.person = person;
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

-(void)expandWithRelatedEvents:(NSArray *)events completion:(void(^)(BOOL expanded))completion {
    publicExpandCompletion = completion;
    relatedEventArray = events;
    [self expandWithCompletion:[self expandCompletionBlock]];
}

-(void)collapseWithCompletion:(void(^)(BOOL expanded))completion {
    publicExpandCompletion = completion;
    [self collapseWithCompletionBlock:[self collapseCompletionBlock]];
}

-(void(^)(void))collapseCompletionBlock {
    return ^{
        

        rowHeightDelta = [NSNumber numberWithFloat:0];
//        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForFigureRowHeightChanged
//                                                            object:self
//                                                          userInfo:@{@"delta": heightDifference}];
        publicExpandCompletion(NO);
    };
}


-(void(^)(NSNumber *))expandCompletionBlock {
    return ^(NSNumber *delta){
        
        rowHeightDelta = [NSNumber numberWithFloat:[rowHeightDelta floatValue] + [delta floatValue]];

//        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForFigureRowHeightChanged
//                                                            object:self
//                                                          userInfo:@{@"delta": delta}];
        publicExpandCompletion(YES);
    };
}


-(void)putRelatedEventsAndExpandWithCompletion:(void(^)(NSNumber *heightIncrease))completionBlock {
    
        NSLog(@"Events: %@", relatedEventArray);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for (int i=0; i < relatedEventArray.count; i++) {
                Event *relatedEvent = [relatedEventArray objectAtIndex:i];
                    RelatedEventLabel *eventLabel = [[RelatedEventLabel alloc] initWithRelatedEvent:relatedEvent];
                eventLabel.alpha = 0;
                eventLabel.frame = CGRectMake(0, viewFrame.expanded.size.height + RelatedEventsLabelHeight * i, RelatedEventsLabelWidth, RelatedEventsLabelHeight);
                
//                if (relatedEvent.isSelf == YES) {
//                    selfEventRightmostPoint = CGPointMake(CGRectGetMaxX(eventLabel.frame), CGRectGetMaxY(eventLabel.frame) - CGRectGetHeight(eventLabel.frame) / 2);
//                    eventLabel.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:.2].CGColor;
//                    eventLabel.layer.cornerRadius = 15.0;
//                }
                
                [self.view addSubview:eventLabel];
                [arrayOfRelatedEventLabels addObject:eventLabel];
            }
            CGFloat contentSizeIncrease = RelatedEventsLabelHeight * [relatedEventArray count] + viewFrame.expanded.size.height - viewFrame.collapsed.size.height;
            CGFloat frameDelta;
            CGRect keyWindowFrame = Utility_AppSettings.frameForKeyWindow;
            CGFloat availableHeight = keyWindowFrame.size.height - MoreCloseButtonHeight - 20 - 44;
            frameDelta = availableHeight - viewFrame.collapsed.size.height;
            
            CGRect newContentRect = CGRectMake(0, 0, viewFrame.collapsed.size.width, viewFrame.collapsed.size.height + contentSizeIncrease);
            CGRect newFrameRect = CGRectAddHeightToRect(viewFrame.collapsed, frameDelta);
            newFrameRect = CGRectMakeFrameWithSizeFromFrame(newFrameRect);
            newFrameRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, newFrameRect.size.width, newFrameRect.size.height);
            self.frame =  newFrameRect;
            __block NSNumber *frameDeltaNumber;
            frameDeltaNumber = [NSNumber numberWithFloat:frameDelta];
                
                [self setContentFrames:newContentRect];
                    for (UILabel *theLabel in arrayOfRelatedEventLabels) {
                        theLabel.alpha = 1;
                    }

                    [self addIndicatorLines];
            completionBlock(frameDeltaNumber);

        });
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
    
    if (rect.size.height < self.bounds.size.height) {
        rect = self.bounds;
    }
    self.view.frame = rect;
    self.contentSize = CGSizeMakeFromRect(rect);
}

-(void)setFrame:(CGRect)frame {
//    [self setContentFrames:frame];
    [super setFrame:frame];
}

-(void)expandWithCompletion:(void(^)(NSNumber *))completionBlock {
    
        [CATransaction begin];
    [CATransaction setAnimationDuration:0.5];
        [self.widgetContainer expandWidget];
        eventDescriptionText.layer.frame = descriptionFrame.expanded;
        eventDescriptionText.layer.opacity = 0;
        self.widgetContainer.frame = widgetContainerFrame.expanded;
        ageLabel.frame = ageLabelFrame.expanded;
        ageLabel.layer.opacity = 0;
        [CATransaction commit];
        _expanded = YES;
        eventDescriptionText.frame = descriptionFrame.expanded;
        [self putRelatedEventsAndExpandWithCompletion:completionBlock];
        self.scrollEnabled = YES;
}

-(void)collapseWithCompletionBlock:(void(^)(void))completionBlock {
    
    
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
        eventDescriptionText.frame = descriptionFrame.collapsed;
        
        for (UILabel *relatedEventLabel in arrayOfRelatedEventLabels) {
            [relatedEventLabel removeFromSuperview];
        }
        self.scrollEnabled = NO;
        
        completionBlock();
}

#pragma mark FigureRowPageProtocol Functions

-(CGFloat)rightPageMargin {
    return SpaceBetweenFigureRowPages;
}


@end
