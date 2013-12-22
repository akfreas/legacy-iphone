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
    UIButton *facebookButton;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = HeaderBackgroundColor;
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}
-(void)addActionComponents {
    
    facebookButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [facebookButton setImage:[UIImage imageNamed:@"facebook-icon"] forState:UIControlStateNormal];
    [self.contentView insertSubview:facebookButton belowSubview:figureRow];
    [facebookButton bk_addEventHandler:^(id sender) {
        NSLog(@"Captured hit.");
    } forControlEvents:UIControlEventTouchUpInside];
    UIBind(facebookButton, figureRow);
    [self.contentView addConstraintWithVisualFormat:@"H:|-[facebookButton(20)]" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|-[facebookButton]-|" bindings:BBindings];
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
//    [arrowView addConstraintWithVisualFormat:@"H:|[arrowImage]|" bindings:BBindings];
//    [arrowView addConstraintWithVisualFormat:@"V:|[arrowImage]|" bindings:BBindings];

    [self.contentView addSubview:arrowView];
    [self.contentView addConstraintWithVisualFormat:@"V:|[arrowView]|" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"H:[arrowView(20)]|" bindings:BBindings];
}

-(void)reset {
    if ([row isKindOfClass:figureRow.class]) {
        [(FigureRowHorizontalScrollView *)row closeDrawer:NULL];
    }
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
            [self addActionComponents];

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
    [self.contentView addConstraintWithVisualFormat:@"H:|[row]|" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|[row]|" bindings:BBindings];
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
