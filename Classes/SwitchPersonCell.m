#import "SwitchPersonCell.h"

@implementation SwitchPersonCell {
    
    NSString *name;
    NSString *birthday;
}

-(void)configureCellWithName:(NSString *)theName birthday:(NSString *)theBirthday {
    
    name = theName;
    birthday = theBirthday;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 4, 100, 36)];
    nameLabel.text = name;
    nameLabel.textAlignment = UITextAlignmentLeft;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [Utility_AppSettings applicationFontMedium];
    
    [self addSubview:nameLabel];
    
    UILabel *birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(175, 4, 100, 36)];
    birthdayLabel.text = birthday;
    birthdayLabel.backgroundColor = [UIColor clearColor];
    birthdayLabel.textAlignment = UITextAlignmentRight;
    birthdayLabel.font = [Utility_AppSettings applicationFontMedium];
    
    [self addSubview:birthdayLabel];
}

@end