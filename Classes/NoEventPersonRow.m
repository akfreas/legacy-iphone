#import "NoEventPersonRow.h"
#import "Person.h"
#import "CircleImageView.h"

@implementation NoEventPersonRow {
    
    IBOutlet UIView *profilePictureHostingView;
    IBOutlet UILabel *messageStringLabel;
    IBOutlet UILabel *firstNameLabel;
    CircleImageView *personProfileCircleImageView;
    
}

- (id)initWithFrame:(CGRect)frame
{
    NSArray *bundleArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil];
    self = bundleArray[0];
    if (self) {
        self.frame = CGRectSetOriginOnRect(self.frame, frame.origin.x, frame.origin.y);
        messageStringLabel.font = firstNameLabel.font = [UIFont fontWithName:@"Cinzel-Regular" size:14.0f];
    }
    return self;
}

-(void)setPerson:(Person *)person {
    _person = person;
    if (personProfileCircleImageView == nil) {
        personProfileCircleImageView = [[CircleImageView alloc] initWithImage:[UIImage imageWithData:person.thumbnail] radius:profilePictureHostingView.frame.size.height / 2];
        personProfileCircleImageView.frame = profilePictureHostingView.bounds;
        [profilePictureHostingView addSubview:personProfileCircleImageView];
    } else {
        personProfileCircleImageView.image = [UIImage imageWithData:person.thumbnail];
    }
    if (_person != nil) {
        [self addObserver:self forKeyPath:@"self.person.thumbnail" options:NSKeyValueObservingOptionNew context:nil];
        firstNameLabel.text = person.firstName;
        [self setMessageString:@"No Event Today"];
    }
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    id newObject = change[NSKeyValueChangeNewKey];
    if (newObject != nil && [newObject isKindOfClass:[NSData class]]) {
        personProfileCircleImageView.image = [UIImage imageWithData:newObject];
    }
}

-(void)setMessageString:(NSString *)messageString {
    messageStringLabel.text = messageString;
}


@end
