#import "FigureRowCell.h"
#import "FigureRow.h"
#import "EventPersonRelation.h"
#import "NoEventPersonRow.h"
#import "RowProtocol.h"

@implementation FigureRowCell {
    UIView <RowProtocol> *row;
    
    NoEventPersonRow *noEventRow;
    FigureRow *figureRow;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
-(void)setSelected:(BOOL)selected {
    row.selected = selected;
}

-(BOOL)isSelected {
    return row.selected;
}
-(void)setEventPersonRelation:(EventPersonRelation *)eventPersonRelation {
    
    UIView <RowProtocol> *rowView;
    if (eventPersonRelation.event == nil && eventPersonRelation.person != nil) {
        if (noEventRow == nil) {
            noEventRow = [[NoEventPersonRow alloc] init];
        }
        noEventRow.person = eventPersonRelation.person;
        rowView = noEventRow;
    } else if (eventPersonRelation.event != nil) {
        if (figureRow == nil) {
            figureRow = [[FigureRow alloc] initWithOrigin:CGPointZero];
        }
        figureRow.person = eventPersonRelation.person;
        figureRow.event = eventPersonRelation.event;
        rowView = figureRow;
    } else {
        NSLog(@"Wat.");
    }
    
    [row removeFromSuperview];
    row = rowView;
    [self addSubview:row];
}

-(Person *)person {
    return self.eventPersonRelation.person;
}

-(Event *)event {
    return self.eventPersonRelation.event;
}

-(CGFloat)height {
    return row.frame.size.height;
}


@end
