#import "FigureTimelineEventCell.h"
#import "RelatedEventLabel.h"
#import "Event.h"
#import <CoreGraphics/CoreGraphics.h>


@interface FigureTimelineCellLinePointView : UIView

@property (nonatomic, assign) BOOL isKey;
@property (nonatomic, assign) BOOL isTerminalCell;
@property (nonatomic, assign) CGPoint pointOrigin;
@end
@implementation FigureTimelineCellLinePointView

-(id)initWithFrame:(CGRect)frame pointOrigin:(CGPoint)pointOrigin {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.pointOrigin = pointOrigin;
    }
    return self;
}
-(void)setIsTerminalCell:(BOOL)isTerminalCell {
    _isTerminalCell = isTerminalCell;
    [self setNeedsDisplay];
}
-(void)setIsKey:(BOOL)isKey {
    _isKey = isKey;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect {
    
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = EventHeaderCellLineStrokeWidth;
    aPath.lineCapStyle = kCGLineCapRound;
    CGFloat startX = 20;
    CGFloat arcRadius = 4;
    CGFloat arcOrigin = self.pointOrigin.y;
    [HeaderBackgroundColor setStroke];
    [aPath moveToPoint:CGPointMake(startX, 0)];
    CGPoint lastLinePoint = CGPointMake(startX, arcOrigin - arcRadius);
    [aPath addLineToPoint:lastLinePoint];
    [aPath addArcWithCenter:CGPointMake(startX, arcOrigin) radius:arcRadius startAngle:DEG2RAD(-90) endAngle:DEG2RAD(270) clockwise:YES];
    if (self.isTerminalCell == NO) {
        [aPath moveToPoint:CGPointMake(startX, lastLinePoint.y + arcRadius * 2)];
        [aPath addLineToPoint:CGPointMake(startX, self.frame.size.height)];
    }
    if (self.isKey) {
        [HeaderBackgroundColor setFill];
        [aPath fill];
    }
    [aPath stroke];
}
@end

@interface FigureTimelineEventCell ()

@property (strong, nonatomic, readwrite) NSString *reuseIdentifier;

@end

@implementation FigureTimelineEventCell {

    
    IBOutlet UITextView *textView;
    IBOutlet UILabel *ageLabel;
    NSString *reuseID;
    FigureTimelineCellLinePointView *contentView;
}

-(id)initWithEvent:(Event *)anEvent reuseIdentifier:(NSString *)reuseIdentifier {
    
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])  owner:self options:nil];
    self = [nibArray objectAtIndex:0];
//    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _event = anEvent;
        reuseID = reuseIdentifier;
        
        contentView = [[FigureTimelineCellLinePointView alloc] initWithFrame:self.frame pointOrigin:CGPointMake(0, CGRectGetMidY(ageLabel.frame))];
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

-(void)setIsTerminalCell:(BOOL)isTerminalCell {
    contentView.isTerminalCell = isTerminalCell;
}
-(void)setShowAsKey:(BOOL)showAsKey {
    contentView.isKey = showAsKey;
}

@end

