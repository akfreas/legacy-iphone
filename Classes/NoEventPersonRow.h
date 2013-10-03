#import "RowProtocol.h"
@class Person;


@interface NoEventPersonRow : UIView <RowProtocol>

@property (strong, nonatomic) Person *person;
@property (strong, nonatomic) NSString *messageString;
@property (nonatomic, assign) BOOL selected;

@end
