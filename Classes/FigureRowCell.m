#import "FigureRowCell.h"
#import "FigureRow.h"
#import "EventPersonRelation.h"
#import "NoEventPersonRow.h"
#import "RowProtocol.h"
#import "Event.h"
#import "Figure.h"

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

-(void)createImageFromView:(UIView *)view name:(NSString *)name

{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *_fileName = [NSString stringWithFormat:@"%@.jpg", name];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:_fileName];
    
    /* creating image context to create an image using view */
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 2.0);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    [imageData writeToFile:filePath atomically:YES];
    
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
