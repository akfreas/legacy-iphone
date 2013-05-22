#include "CGRectUtils.h"

CGRect CGRectMakeFrameForCenter(UIView *view, CGSize size, CGFloat yPos) {
    
    CGRect viewRect = view.frame;
    CGRect newRect = CGRectMake(viewRect.size.width / 2 - size.width / 2, yPos, size.width, size.height);
    return newRect;
}

CGRect CGRectMakeFrameWithSizeFromFrame(CGRect rect) {
    return CGRectMake(0, 0, rect.size.width, rect.size.height);
}

CGPoint CGPointGetCenterFromRect(CGRect rect) {
    return CGPointMake(rect.size.width / 2, rect.size.height /2);
}
