#import "PersonInfoView.h"
#import "Utility_AppSettings.h"
#import "Person.h"

@implementation PersonInfoView {
    
    
    IBOutlet UIImageView *personThumbnail;
    IBOutlet UILabel *birthdayLabel;
    IBOutlet UILabel *firstNameLabel;
    IBOutlet UILabel *lastNameLabel;
    IBOutlet UIView *personView;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"PersonInfoView" owner:self options:nil];
        [self addSubview:personView];
    }
    
    return self;
}

-(void)layoutSubviews {
    
    birthdayLabel.text = [[Utility_AppSettings dateFormatterForDisplay] stringFromDate:_person.birthday];
//    firstNameLabel.text =  [NSString stringWithFormat:@"%@ %@", _person.firstName, _person.lastName];
    firstNameLabel.text = _person.firstName;
//    lastNameLabel.transform = CGAffineTransformMakeRotation(M_PI/-2);
    UIImage *thumbnail = [UIImage imageWithData:_person.thumbnail];
    personThumbnail.image = thumbnail;
}

-(void)setPerson:(Person *)person {
    _person = person;
    [self setNeedsLayout];
}

@end