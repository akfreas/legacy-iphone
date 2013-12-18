#import "FigureRowCell.h"
#import "FigureRowHorizontalScrollView.h"
#import "EventPersonRelation.h"
#import "NoEventPersonRow.h"
#import "RowProtocol.h"
#import "Event.h"
#import "Figure.h"

@implementation FigureRowCell {
    UIView <RowProtocol> *row;
    
    NoEventPersonRow *noEventRow;
    FigureRowHorizontalScrollView *figureRow;
    UIView *arrowView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    return self;
}

-(void)addArrowView {
    arrowView = [[UIView alloc] initWithFrame:CGRectZero];
    arrowView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next-arrow-gray"]];
    [arrowView addSubview:arrowImage];
    [arrowView addConstraint:[NSLayoutConstraint constraintWithItem:arrowImage
                                                          attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:arrowView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [arrowView addConstraint:[NSLayoutConstraint constraintWithItem:arrowImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:arrowView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    UIBind(arrowView, arrowImage);
//    [arrowView addConstraintWithVisualFormat:@"H:|[arrowImage]|" bindings:UIBindings];
//    [arrowView addConstraintWithVisualFormat:@"V:|[arrowImage]|" bindings:UIBindings];

    [self.contentView addSubview:arrowView];
    [self.contentView addConstraintWithVisualFormat:@"V:|[arrowView]|" bindings:UIBindings];
    [self.contentView addConstraintWithVisualFormat:@"H:[arrowView(20)]|" bindings:UIBindings];
}

-(void)reset {
    if ([row isKindOfClass:figureRow.class]) {
        [(FigureRowHorizontalScrollView *)row reset];
    }
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
            figureRow = [[FigureRowHorizontalScrollView alloc] initWithFrame:CGRectZero];
        }
        figureRow.person = eventPersonRelation.person;
        figureRow.event = eventPersonRelation.event;
        rowView = figureRow;
    } else {
        NSLog(@"Wat.");
    }
    [row removeFromSuperview];
    row = rowView;
    [self.contentView addSubview:row];
    UIBind(row);
    [self.contentView addConstraintWithVisualFormat:@"H:|[row]|" bindings:UIBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|[row]|" bindings:UIBindings];
    if (arrowView == nil) {
        [self addArrowView];
    }
}

-(void)createImageFromView:(UIView *)view name:(NSString *)name {
    
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

@end
