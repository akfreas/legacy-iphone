//
//  TopActionView.h
//  Legacy
//
//  Created by Alexander Freas on 6/23/13.
//
//

#import <UIKit/UIKit.h>

@interface TopActionView : UIView

@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, strong) UIColor *tintColor;

-(void)addFriendsButtonTappedAction;

@end
