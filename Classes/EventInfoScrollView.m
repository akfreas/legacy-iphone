#import "EventInfoScrollView.h"
#import "ObjectArchiveAccessor.h"
#import "Person.h"
#import "AtYourAgeRequest.h"
#import "AtYourAgeConnection.h"
#import "EventDescriptionView.h"
#import "FigureRow.h"


@implementation EventInfoScrollView {
    ObjectArchiveAccessor *accessor;
    NSMutableArray *arrayOfFigureRows;
    NSFetchedResultsController *fetchedResultsController;
    AtYourAgeConnection *connection;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.contentSize = CGSizeMake(320, Utility_AppSettings.frameForKeyWindow.size.height);
        accessor = [ObjectArchiveAccessor sharedInstance];
        arrayOfFigureRows = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor colorWithRed:13/255 green:20/355 blue:20/255 alpha:1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(figureRowHeightChanged:) name:KeyForFigureRowContentChanged object:nil];
    }
    return self;
}


-(void)addInfoViews {
    
    NSArray *eventsInStore = [accessor getStoredEvents];
    
    for (int i=0; i<[eventsInStore count]; i++) {
        
        
        Event *theEvent = [eventsInStore objectAtIndex:i];
        
        __block FigureRow *row = [[FigureRow alloc] initWithOrigin:CGPointMake(0, (FigureRowPageInitialHeight + EventInfoScrollViewPadding) * i)];
        [arrayOfFigureRows addObject:row];
        [self addSubview:row];
        row.event = theEvent;
        
        
        self.contentSize = CGSizeMake(self.contentSize.width, (i + 1) * (FigureRowPageInitialHeight + EventInfoScrollViewPadding));
    }
    
    [self setNeedsLayout];
}

-(void)figureRowHeightChanged:(NSNotification *)notification {
    FigureRow *rowToResize = notification.object;
    CGFloat heightOffset = [notification.userInfo[@"delta"] floatValue];
    
    NSInteger firstIndex = [arrayOfFigureRows indexOfObject:rowToResize];
    
    self.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height + heightOffset);

        for (int i=firstIndex + 1; i<[arrayOfFigureRows count]; i++) {
            FigureRow *rowToOffset = [arrayOfFigureRows objectAtIndex:i];
            rowToOffset.frame = CGRectMake(rowToOffset.frame.origin.x, rowToOffset.frame.origin.y + heightOffset,  rowToOffset.frame.size.width, rowToOffset.frame.size.height);
        }
        
        if (heightOffset > 0) {
            self.scrollEnabled = NO;
            FigureRow *openRow = [arrayOfFigureRows objectAtIndex:firstIndex];
            [self setContentOffset:openRow.frame.origin animated:YES];
        } else {
            self.scrollEnabled = YES;
            if (firstIndex > 0 && firstIndex != [arrayOfFigureRows count] - 1) {
                FigureRow *rowAbove = [arrayOfFigureRows objectAtIndex:firstIndex - 1];
                [self setContentOffset:CGPointMake(0, CGRectGetMidY(rowAbove.frame)) animated:YES];
            }
        }
    
}

-(CGRect)frameAtIndex:(NSInteger)index {
    CGFloat padding = 5;
    CGFloat width = Utility_AppSettings.frameForKeyWindow.size.height;

    return CGRectMake(0, (FigureRowPageInitialHeight + EventInfoScrollViewPadding)  * index, width, FigureRowPageInitialHeight);
}

-(void)removeInfoViews {
    for (UIView *infoView in arrayOfFigureRows) {
        [infoView removeFromSuperview];
    }
    [arrayOfFigureRows removeAllObjects];
}

-(void)reload {
    [self removeInfoViews];
    [self addInfoViews];
}

@end
