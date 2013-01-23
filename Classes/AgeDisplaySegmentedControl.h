@interface AgeDisplaySegmentedControl : UIView

- (id)initWithYears:(NSString *)theYears months:(NSString *)theMonths days:(NSString *)theDays;

-(void)updateWithYears:(NSString *)theYears months:(NSString *)theMonths days:(NSString *)theDays;

@end