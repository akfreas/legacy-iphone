#import "FigureRowCell.h"
#import "FigureRow.h"

@implementation FigureRowCell {
    FigureRow *row;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        row = [[FigureRow alloc] initWithOrigin:CGPointZero];
        [self addSubview:row];
    }
    return self;
}
-(void)setSelected:(BOOL)selected {
    row.selected = selected;
}

-(BOOL)isSelected {
    return row.selected;
}

-(void)setEvent:(Event *)event {
    row.event = event;
}

-(void)setPerson:(Person *)person {
    row.person = person;
}

-(Person *)person {
    return row.person;
}

-(Event *)event {
    return row.event;
}


@end
