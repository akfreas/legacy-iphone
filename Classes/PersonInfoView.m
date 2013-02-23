#import "PersonInfoView.h"
#import "Utility_AppSettings.h"
#import "Person.h"

@implementation PersonInfoView {
    
    Person *thePerson;
    
    IBOutlet UIImageView *personThumbnail;
    IBOutlet UILabel *birthdayLabel;
    IBOutlet UILabel *firstNameLabel;
    IBOutlet UILabel *lastNameLabel;
    IBOutlet UIView *personView;
}


-(id)initWithPerson:(Person *)aPerson {
    self = [super init];
    
    if (self) {
        thePerson = aPerson;
        [[NSBundle mainBundle] loadNibNamed:@"PersonInfoView" owner:self options:nil];
    }
    
    return self;
}

-(void)layoutSubviews {
    
    birthdayLabel.text = [[Utility_AppSettings dateFormatterForDisplay] stringFromDate:thePerson.birthday];
    firstNameLabel.text = thePerson.firstName;
    lastNameLabel.text = thePerson.lastName;
    lastNameLabel.transform = CGAffineTransformMakeRotation(M_PI/-2);
    UIImage *thumbnail = [UIImage imageWithData:thePerson.thumbnail];
    personThumbnail.image = thumbnail;
    
    [self addSubview:personView];
}




@end
