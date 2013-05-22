#ifndef CGRECTUTILS_H
#define CGRECTUTILS_H
#endif
#import <CoreGraphics/CoreGraphics.h>

inline CGRect CGRectMakeFrameForCenter(UIView *view, CGSize size, CGFloat yPos);
inline CGRect CGRectMakeFrameWithSizeFromFrame(CGRect rect);
inline CGPoint CGPointGetCenterFromRect(CGRect rect);