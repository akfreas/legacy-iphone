#import "PersonInfoView.h"
#import "Utility_AppSettings.h"
#import "Person.h"

@implementation PersonInfoView {
    
    Person *thePerson;
    
    IBOutlet UIImageView *personThumbnail;
    IBOutlet UILabel *birthdayLabel;
    IBOutlet UILabel *nameLabel;
}


-(id)initWithPerson:(Person *)aPerson {
    self = [super init];
    
    if (self) {
        thePerson = aPerson;
        [[NSBundle mainBundle] loadNibNamed:@"PersonInfoView" owner:self options:nil];
    }
    
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    birthdayLabel.text = [[Utility_AppSettings dateFormatterForDisplay] stringFromDate:thePerson.birthday];
    nameLabel.text = [NSString stringWithFormat:@"%@ %@", thePerson.firstName, thePerson.lastName];
    UIImage *thumbnail = [UIImage imageWithData:thePerson.thumbnail];
    personThumbnail = [[UIImageView alloc] initWithImage:thumbnail];
}





@end
