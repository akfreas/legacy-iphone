#import "DescriptionPage.h"
#import "Person.h"

@implementation DescriptionPage {
    
    Person *person;
    
    IBOutlet UITextView *descriptionText;
}

- (id)initWithPerson:(Person *)thePerson;
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 200)];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"DescriptionPage" owner:self options:nil];
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


@end
