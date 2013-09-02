#import "EventInfoTimelineCell.h"
#import "RelatedEventLabel.h"
#import "Event.h"

@interface EventInfoTimelineCell ()

@property (strong, nonatomic, readwrite) NSString *reuseIdentifier;

@end

@implementation EventInfoTimelineCell {

    
    IBOutlet UITextView *textView;
    IBOutlet UILabel *ageLabel;
}

-(id)initWithEvent:(Event *)anEvent {
    
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])  owner:self options:nil];
    self = [nibArray objectAtIndex:0];
    
    if (self) {
        _event = anEvent;
        self.reuseIdentifier = TableViewCellIdentifierForMainCell;
//        self.backgroundColor = [UIColor redColor];
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




@end
