#import "EventRowCell.h"
#import "EventRowHorizontalScrollView.h"
#import "EventPersonRelation.h"
#import "Event.h"
#import "Figure.h"

@implementation EventRowCell {
    
    EventRowHorizontalScrollView *eventRowScrollView;
    UIView *arrowView;
    UIButton *facebookButton;
    UIButton *twitterButton;
    UIButton *arrowButton;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = HeaderBackgroundColor;
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addEventRowScrollView];
        [self addDrawerItems];
    }
    return self;
}

-(void)addDrawerItems {
    [self addFacebookButton];
    [self addTwitterButton];
    [self addArrowButton];
    [self addLayoutConstraints];
}

-(void)addLayoutConstraints {
    UIBind(facebookButton, twitterButton, eventRowScrollView);

    [self.contentView addConstraintWithVisualFormat:@"H:|-(>=15)-[facebookButton(20)]-(>=20)-[twitterButton(20)]" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|[facebookButton]|" bindings:BBindings];
    [twitterButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.contentView];
}

-(void)addArrowButton {
    
}

-(void)addTwitterButton {
    
    twitterButton = [[UIButton alloc] initForAutoLayout];
    [twitterButton setImage:TwitterButtonImage forState:UIControlStateNormal];
    [self.contentView insertSubview:twitterButton belowSubview:eventRowScrollView];
    [twitterButton bk_addEventHandler:^(id sender) {
        
    } forControlEvents:UIControlEventTouchUpInside];
}

-(void)addFacebookButton {
    
    facebookButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [facebookButton setImage:[UIImage imageNamed:@"facebook-icon"] forState:UIControlStateNormal];
    [self.contentView insertSubview:facebookButton belowSubview:eventRowScrollView];
    [facebookButton bk_addEventHandler:^(id sender) {
        NSLog(@"Captured hit.");
    } forControlEvents:UIControlEventTouchUpInside];
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
    
    eventRowScrollView = [[EventRowHorizontalScrollView alloc] initForAutoLayout];
    [self.contentView addSubview:eventRowScrollView];
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
