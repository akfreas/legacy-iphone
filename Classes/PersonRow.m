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


+ (Class)layerClass {
    
    return [CAGradientLayer class];
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"PersonRow" owner:self options:nil];
//        NSMutableArray *colors = [NSMutableArray array];
//        [colors addObject:[UIColor colorWithWhite:1.0 alpha:1.0]];
//        [colors addObject:[UIColor clearColor]];
//        CAGradientLayer *gradient = [[CAGradientLayer alloc] initWithLayer:mainInfoHostingView.layer];
//        [gradient setColors:colors];
//        
//        [gradient setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.48], [NSNumber numberWithFloat:1.0], nil]];
//        
//        
//        
        // Set the colors for the gradient layer.
        static NSMutableArray *colors = nil;
        if (colors == nil) {
            colors = [[NSMutableArray alloc] initWithCapacity:3];
            UIColor *color = nil;
            [colors addObject:(id)[UIColor clearColor].CGColor];
            color = [UIColor colorWithWhite:1.0 alpha:0.5];
            [colors addObject:(id)[color CGColor]];
        }
        
        CAGradientLayer *gradient = (CAGradientLayer *)mainInfoHostingView.layer;
        [gradient setColors:colors];
        [gradient setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.00], [NSNumber numberWithFloat:0.1], nil]];
        gradient.startPoint = CGPointMake(0, 0);
        gradient.endPoint =CGPointMake(1, 0);

//        [mainInfoHostingView.layer addSublayer:gradient];
//        [(CAGradientLayer *)view.layer addSublayer:; setColors:colors];
        
        [self addSubview:view];
    }
    return self;
}
//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef currentContext = UIGraphicsGetCurrentContext();
//    
//    CGGradientRef glossGradient;
//    CGColorSpaceRef rgbColorspace;
//    size_t num_locations = 2;
//    CGFloat locations[2] = { 0.0, 1.0 };
//    CGFloat components[8] = { 0.0, 0.0, 0.0, 0.35,  // Start color
//        1.0, 1.0, 1.0, 0.06 }; // End color
//    
//    rgbColorspace = CGColorSpaceCreateDeviceRGB();
//    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
//
//    CGRect currentBounds = self.bounds;
//    CGPoint topCenter = CGPointMake(CGRectGetMaxX(currentBounds), CGRectGetMidY(currentBounds));
//    CGPoint midCenter = CGPointMake(CGRectGetMinX(currentBounds), CGRectGetMidY(currentBounds));
//    CGCo~~ntextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);

//    CGGradientRelease(glossGradient);
//    CGColorSpaceRelease(rgbColorspace);
//}

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
