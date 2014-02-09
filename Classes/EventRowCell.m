#import "EventRowCell.h"
#import "EventRowHorizontalScrollView.h"
#import "EventPersonRelation.h"
#import "Event.h"
#import "Figure.h"
#import <Social/Social.h>

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
    [self.contentView addConstraintWithVisualFormat:@"H:|[facebookButton(45)][twitterButton(45)]" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|[facebookButton]|" bindings:BBindings];
    [self.contentView addConstraintWithVisualFormat:@"V:|[twitterButton]|" bindings:BBindings];
    [twitterButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.contentView];
}

-(void)addArrowButton {
    
}

-(void)addTwitterButton {
    
    twitterButton = [[UIButton alloc] initForAutoLayout];
    twitterButton.imageView.contentMode = UIViewContentModeCenter;
    twitterButton.backgroundColor = LightButtonColor;
    [twitterButton setImage:TwitterButtonImage forState:UIControlStateNormal];
    [self.contentView insertSubview:twitterButton belowSubview:eventRowScrollView];
    [twitterButton bk_addEventHandler:^(id sender) {
        SLComposeViewController *compose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [compose addURL:[self wikipediaURL]];
        [compose addImage:self.relation.event.figure.image];
        [compose setInitialText:[self shortDescriptionString]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:compose animated:YES completion:NULL];
    } forControlEvents:UIControlEventTouchUpInside];
}

-(void)addFacebookButton {
    
    facebookButton = [[UIButton alloc] initWithFrame:CGRectZero];
    facebookButton.imageView.contentMode = UIViewContentModeCenter;
    [facebookButton setImage:FacebookButtonImage forState:UIControlStateNormal];
    [self.contentView insertSubview:facebookButton belowSubview:eventRowScrollView];
    [facebookButton bk_addEventHandler:^(id sender) {
        NSLog(@"Captured hit.");
        [FBDialogs presentShareDialogWithLink:[self wikipediaURL] name:self.relation.event.figure.name caption:[self eventDescriptionString] description:[self eventDescriptionString] picture:[NSURL URLWithString:self.relation.event.figure.imageURL] clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            
        }];
    } forControlEvents:UIControlEventTouchUpInside];
}
-(NSString *)shortDescriptionString {
    
    NSString *eventNameAgeString = [NSString stringWithFormat:@"%@: %@y, %@m, %@d old, %@", self.relation.event.figure.name, self.relation.event.ageYears, self.relation.event.ageMonths, self.relation.event.ageDays, self.relation.event.eventDescription];
    NSString *shortenedString = [eventNameAgeString length] > 100 ? [NSString stringWithFormat:@"%@...", [eventNameAgeString substringToIndex:97]] : eventNameAgeString;
    return shortenedString;
}
-(NSString *)eventDescriptionString {
    
    NSString *eventAgeString = [NSString stringWithFormat:@"@%@ years, %@ months, %@ days old ", self.relation.event.ageYears, self.relation.event.ageMonths, self.relation.event.ageDays];
    return [NSString stringWithFormat:@"%@: %@", eventAgeString, self.relation.event.eventDescription];
}

-(NSURL *)wikipediaURL {
    
    NSString *nameWithUnderscores = [self.relation.event.figure.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSURL *wikipediaURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@", nameWithUnderscores]];
    return wikipediaURL;
}

-(void)reset {
    if ([eventRowScrollView isKindOfClass:eventRowScrollView.class]) {
        [(EventRowHorizontalScrollView *)eventRowScrollView closeDrawer:NULL];
    }
}

-(void)setRelation:(EventPersonRelation *)relation {
    _relation = relation;
    eventRowScrollView.relation = relation;
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
    return self.relation.person;
}

-(Event *)event {
    return self.relation.event;
}

@end
