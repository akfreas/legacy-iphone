@interface User : NSObject <NSCoding>

@property (nonatomic) NSDate *birthday;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *facebookId;

@end