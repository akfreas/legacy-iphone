#import "LegacyInfoPage.h"

@implementation LegacyInfoPage {
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil][0];
    if (self) {
        self.frame = frame;
    }
    return self;
}

@end
