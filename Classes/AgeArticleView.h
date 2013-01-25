@class User;
@interface AgeArticleView : UIView <UIWebViewDelegate>

- (id)initWithUser:(User *)theUser;
-(void)updateWithUser:(User *)theUser;

@end
