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
    nameLabel.font = [Utility_UISettings applicationFontMedium];
    
    [self addSubview:nameLabel];
    
    UILabel *birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(175, 4, 100, 36)];
    birthdayLabel.text = birthday;
    birthdayLabel.textAlignment = UITextAlignmentRight;
    birthdayLabel.font = [Utility_UISettings applicationFontMedium];
    
    [self addSubview:birthdayLabel];
}

@end