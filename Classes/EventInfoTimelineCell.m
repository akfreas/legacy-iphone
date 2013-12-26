#import "EventInfoTimelineCell.h"
#import "RelatedEventLabel.h"
#import "Event.h"
#import <CoreGraphics/CoreGraphics.h>


@interface EventInfoTimelineCellContentView : UIView

@property (assign) BOOL isKey;

@end
@implementation EventInfoTimelineCellContentView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    return self;
}


-(void)drawRect:(CGRect)rect {
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = EventHeaderCellLineStrokeWidth;
    aPath.lineCapStyle = kCGLineCapRound;
    CGFloat startX = 20;
    CGFloat arcRadius = 4;
    CGFloat arcStart = self.bounds.size.height / 2 - arcRadius * 2;
    [HeaderBackgroundColor setStroke];
    [aPath moveToPoint:CGPointMake(startX, 0)];
    CGPoint lastLinePoint = CGPointMake(startX, arcStart - arcRadius);
    [aPath addLineToPoint:lastLinePoint];
    [aPath addArcWithCenter:CGPointMake(startX, arcStart) radius:arcRadius startAngle:DEG2RAD(-90) endAngle:DEG2RAD(270) clockwise:YES];
    [aPath moveToPoint:CGPointMake(startX, lastLinePoint.y + arcRadius * 2)];
    [aPath addLineToPoint:CGPointMake(startX, self.frame.size.height)];
    if (self.isKey) {
        [HeaderBackgroundColor setFill];
        [aPath fill];
    }
    [aPath stroke];
}
@end

@interface EventInfoTimelineCell ()

@property (strong, nonatomic, readwrite) NSString *reuseIdentifier;

@end

@implementation EventInfoTimelineCell {

    
    IBOutlet UITextView *textView;
    IBOutlet UILabel *ageLabel;
    NSString *reuseID;
    EventInfoTimelineCellContentView *contentView;
}

-(id)initWithEvent:(Event *)anEvent reuseIdentifier:(NSString *)reuseIdentifier {
    
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])  owner:self options:nil];
    self = [nibArray objectAtIndex:0];
//    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _event = anEvent;
        reuseID = reuseIdentifier;
        contentView = [[EventInfoTimelineCellContentView alloc] initWithFrame:self.frame];
        [self.contentView addSubview:contentView];
        [self drawEventLabel];
    }
    return self;
}

-(NSString *)reuseIdentifier {
    return reuseID;
}

-(void)drawEventLabel {
    
    ageLabel.text = [NSString stringWithFormat:@"@ %@ years, %@ months, %@ days old ", _event.ageYears, _event.ageMonths, _event.ageDays];
    textView.text = _event.eventDescription;
}

-(void)setEvent:(Event *)event {
    _event = event;
    [self drawEventLabel];
}


-(void)setShowAsKey:(BOOL)showAsKey {
    contentView.isKey = showAsKey;
}

@end

