#import <Foundation/Foundation.h>

@interface FBLoginViewController : UIViewController

-(id)initWithLoggedInCompletion:(void(^)())loggedInCompletionBlock;

@end
