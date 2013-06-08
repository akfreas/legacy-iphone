#import "PersonRowPageProtocol.h"

@interface LeftActionTabPage : UIView <PersonRowPageProtocol>

@property (nonatomic, assign) CGFloat height;

-(id)initWithOrigin:(CGPoint)origin height:(CGFloat)height;

@end
