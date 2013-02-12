#import "AgeDisplaySegmentedControl.h"

@implementation AgeDisplaySegmentedControl {
    
    NSString *years;
    NSString *months;
    NSString *days;
    
    UISegmentedControl *ageCounter;
}

- (id)initWithYears:(NSString *)theYears months:(NSString *)theMonths days:(NSString *)theDays {    
    self = [super init];
    
    if (self) {
        years = theYears;
        months = theMonths;
        days = theDays;
        [self placeAgeCounter];
        [self placeLabels];
    }
    return self;
}

-(void)placeAgeCounter {
    
    if (ageCounter == nil) {
        ageCounter = [[UISegmentedControl alloc] initWithFrame:CGRectMake(10, 15, 260, 35)];
        [ageCounter insertSegmentWithTitle:years atIndex:0 animated:YES];
        [ageCounter insertSegmentWithTitle:months atIndex:1 animated:YES];
        [ageCounter insertSegmentWithTitle:days atIndex:2 animated:YES];
    }
    
    NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"AmericanTypewriter" size:16] forKey:UITextAttributeFont];
    
     
    [ageCounter setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    ageCounter.segmentedControlStyle = UISegmentedControlStyleBordered;
    ageCounter.userInteractionEnabled = NO;
    
    [self addSubview:ageCounter];
}

-(void)updateWithYears:(NSString *)theYears months:(NSString *)theMonths days:(NSString *)theDays {
    

    months = theMonths;
    days = theDays;
    years = theYears;

    [ageCounter setTitle:years forSegmentAtIndex:0];
    [ageCounter setTitle:months forSegmentAtIndex:1];
    [ageCounter setTitle:days forSegmentAtIndex:2];
}

-(void)placeLabels {
    
    UILabel *yearsL = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 86, 15)];
    yearsL.text = @"Years";
    
    
    
    UILabel *monthsL = [[UILabel alloc] initWithFrame:CGRectMake(96, 0, 86, 15)];
    monthsL.text = @"Months";
    
    
    UILabel *daysL = [[UILabel alloc] initWithFrame:CGRectMake(182, 0, 86, 15)];
    daysL.text = @"Days";
    
    
    NSArray *labelArray = [NSArray arrayWithObjects:yearsL, monthsL, daysL, nil];
    
    for (UILabel *label in labelArray) {
        
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [Utility_AppSettings applicationFontSmall];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
    }
}


@end