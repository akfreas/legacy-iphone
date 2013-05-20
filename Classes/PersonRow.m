#import "PersonRow.h"
#import "MainFigureInfoPage.h"

@implementation PersonRow {
    
    MainFigureInfoPage *infoPage;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        infoPage = [[MainFigureInfoPage alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentsChangedSize:) name:KeyForPersonRowHeightChanged object:infoPage];
    }
    return self;
}


-(void)setPerson:(Person *)person {
    _person = person;
    infoPage.person = person;
    [self addSubview:infoPage];
}

-(void)contentsChangedSize:(NSNotification *)notif {
    CGRect f = self.frame;
    CGFloat delta = [[notif.userInfo objectForKey:@"delta"] floatValue];
    
    [UIView animateWithDuration:0 animations:^{
        self.frame = CGRectMake(f.origin.x, f.origin.y, f.size.width, f.size.height + delta);
        [[NSNotificationCenter defaultCenter] postNotificationName:KeyForPersonRowContentChanged object:self userInfo:notif.userInfo];
    }];
    
}

-(void)tapped {
    [infoPage toggleExpand];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
