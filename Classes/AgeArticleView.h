@class User;
@interface AgeArticleView : UIView <UIWebViewDelegate>

- (id)initWithPerson:(User *)theUser;
-(void)updateWithPerson:(User *)theUser;

@end
