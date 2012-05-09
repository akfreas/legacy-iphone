@interface User : NSObject

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSDate *birthday;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;

@end