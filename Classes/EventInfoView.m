#import "EventInfoVIew.h"
#import "Utility_AppSettings.h"
#import "Event.h"

@implementation EventInfoView {
    
    Event *theEvent;
    
    IBOutlet UIImageView *personThumbnail;
    IBOutlet UILabel *birthdayLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UIView *personView;
}


-(id)initWithEvent:(Event *)anEvent {
    self = [super init];
    
    if (self) {
        theEvent = anEvent;
        [[NSBundle mainBundle] loadNibNamed:@"EventInfoView" owner:self options:nil];
    }
    
    return self;
}

-(void)layoutSubviews {
    
    nameLabel.text = [NSString stringWithFormat:@"%@", theEvent.figureName];
    UIImage *thumbnail = [UIImage imageWith];
//    personThumbnail = [[UIImageView alloc] initWithImage:thumbnail];
    
    [self addSubview:personView];
}




@end
