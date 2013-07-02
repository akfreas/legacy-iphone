//
//  AppDelegate.h
//  Legacy
//
//  Created by Alexander Freas on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)openSessionWithCompletionBlock:(void(^)(FBSession *, FBSessionState, NSError *))completionBlock;

@end
