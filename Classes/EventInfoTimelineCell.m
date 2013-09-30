#import "EventInfoTimelineCell.h"
#import "RelatedEventLabel.h"
#import "Event.h"
#import <CoreGraphics/CoreGraphics.h>
@interface EventInfoTimelineCell ()

@property (strong, nonatomic, readwrite) NSString *reuseIdentifier;

@end

@implementation EventInfoTimelineCell {

    
    IBOutlet UITextView *textView;
    IBOutlet UILabel *ageLabel;
    UIView *lineView;
}

-(id)initWithEvent:(Event *)anEvent {
    
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])  owner:self options:nil];
    self = [nibArray objectAtIndex:0];
    
    if (self) {
        _event = anEvent;
        self.reuseIdentifier = TableViewCellIdentifierForMainCell;
        [self drawEventLabel];
    }
    return self;
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
    if (showAsKey == YES) {
        if (lineView == nil) {
            lineView = [[UIView alloc] initWithFrame:CGRectMake(7, ageLabel.frame.origin.y + ageLabel.frame.size.height, ageLabel.frame.size.width, 1)];
            lineView.backgroundColor = [UIColor blackColor];
            [self addSubview:lineView];
        }
        lineView.hidden = NO;
    } else {
        lineView.hidden = YES;
    }
}



@end
