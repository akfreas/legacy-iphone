#import "EventRowCell.h"
#import "EventRowHorizontalScrollView.h"
#import "EventPersonRelation.h"
#import "NoEventPersonRow.h"
#import "RowProtocol.h"
#import "Event.h"
#import "Figure.h"

@implementation EventRowCell {
    
    NoEventPersonRow *noEventRow;
    EventRowHorizontalScrollView *eventRowScrollView;
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
        [self addArrowView];
        [self addEventRowScrollView];
        [self addDrawerItems];
        [self layoutIfNeeded];

    }
    return self;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}
-(void)addDrawerItems {
    
    facebookButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [facebookButton setImage:[UIImage imageNamed:@"facebook-icon"] forState:UIControlStateNormal];
    [self.contentView insertSubview:facebookButton belowSubview:eventRowScrollView];
    [facebookButton bk_addEventHandler:^(id sender) {
        NSLog(@"Captured hit.");
    } forControlEvents:UIControlEventTouchUpInside];
    UIBind(facebookButton, eventRowScrollView);
    [self.contentView addConstraintWithVisualFormat:@"H:|-[facebookButton(20)]" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|-[facebookButton]-|" bindings:BBindings];
}

-(void)addArrowView {
    if (arrowView == nil) {
        arrowView = [[UIView alloc] initWithFrame:CGRectZero];
    arrowView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next-arrow-gray"]];
        arrowImage.translatesAutoresizingMaskIntoConstraints = NO;
    [arrowView addSubview:arrowImage];
    [arrowView addConstraint:[NSLayoutConstraint constraintWithItem:arrowImage
                                                          attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:arrowView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [arrowView addConstraint:[NSLayoutConstraint constraintWithItem:arrowImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:arrowView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        
    [self.contentView addSubview:arrowView];
        UIBind(arrowView);
        [self.contentView addConstraintWithVisualFormat:@"V:|[arrowView]|" bindings:BBindings];
        [self.contentView addConstraintWithVisualFormat:@"H:[arrowView(25)]|" bindings:BBindings];
    }
}

-(void)reset {
    if ([eventRowScrollView isKindOfClass:eventRowScrollView.class]) {
        [(EventRowHorizontalScrollView *)eventRowScrollView closeDrawer:NULL];
    }
}

-(void)setEventPersonRelation:(EventPersonRelation *)eventPersonRelation {
    eventRowScrollView.relation = eventPersonRelation;
}

-(void)addEventRowScrollView {
    
    eventRowScrollView = [[EventRowHorizontalScrollView alloc] initWithFrame:CGRectZero];
    [self.contentView insertSubview:eventRowScrollView belowSubview:arrowView];
    UIBind(eventRowScrollView);
    [self.contentView addConstraintWithVisualFormat:@"H:|[eventRowScrollView]|" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|[eventRowScrollView]|" bindings:BBindings];
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
