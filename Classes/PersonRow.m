#import "PersonRow.h"
#import "MainFigureInfoPage.h"
#import "DescriptionPage.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "ObjectArchiveAccessor.h"
#import "Figure.h"
#import "Event.h"

@implementation PersonRow {
    
    MainFigureInfoPage *infoPage;
    DescriptionPage *descriptionPage;
    AtYourAgeConnection *connection;
    Event *event;
    Figure *figure;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        infoPage = [[MainFigureInfoPage alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentsChangedSize:) name:KeyForPersonRowHeightChanged object:infoPage];
        
        UITapGestureRecognizer *touchUp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:touchUp];
        self.contentSize = CGSizeMake(UIApplication.sharedApplication.keyWindow.frame.size.width * 2, infoPage.frame.size.height);
    }
    return self;
}


-(void)setPerson:(Person *)person {
    _person = person;
    infoPage.person = person;
    
    
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetStoryForPerson:person];
    
    connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, Event *result, NSError *error) {
        NSLog(@"Event Fetch Result: %@", result);
        event = result;
        if (event != nil) {
            [self fetchFigureAndAddDescriptionPage];
            infoPage.event = event;
        }
    }];
    [self addSubview:infoPage];
}


-(void)fetchFigureAndAddDescriptionPage {
    
    
    Person *requester = [[ObjectArchiveAccessor sharedInstance] primaryPerson];
    AtYourAgeRequest *request = [AtYourAgeRequest requestToGetFigureWithId:event.figureId requester:requester];
    
    connection = [[AtYourAgeConnection alloc] initWithAtYourAgeRequest:request];
    
    [connection getWithCompletionBlock:^(AtYourAgeRequest *request, Figure *result, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            figure = result;
            [self addDescriptionPage];
        });
    }];
    
}

-(void)addDescriptionPage {
    
    descriptionPage = [[DescriptionPage alloc] initWithFigure:figure];
    
    descriptionPage.frame = CGRectMake(infoPage.frame.size.width, 0, 320, infoPage.frame.size.height);
    
    [self addSubview:descriptionPage];
    
}

-(void)contentsChangedSize:(NSNotification *)notif {
    CGRect f = self.frame;
    CGFloat delta = [[notif.userInfo objectForKey:@"delta"] floatValue];
    
    [UIView animateWithDuration:0 animations:^{
        self.frame = CGRectMake(f.origin.x, f.origin.y, f.size.width, f.size.height + delta);
        descriptionPage.frame = CGRectMake(infoPage.frame.size.width, 0, 320, infoPage.frame.size.height + delta);

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
