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

CGRect CGRectMakeFrameWithOriginInBottomOfFrame(CGRect hostFrame, CGFloat width, CGFloat height) {
    CGFloat lowerY = CGRectGetHeight(hostFrame) - height;
    CGFloat lowerX = CGRectGetWidth(hostFrame) / 2 - width / 2;
    CGRect newFrame = CGRectMake(lowerX, lowerY, width, height);
    return newFrame;
}


CGRect CGRectMakeFrameWithOriginOnBottomOfFrame(CGRect hostFrame, CGFloat width, CGFloat height) {
    CGFloat lowerY = CGRectGetHeight(hostFrame);
    CGFloat lowerX = CGRectGetWidth(hostFrame) / 2 - width / 2;
    CGRect newFrame = CGRectMake(lowerX, lowerY, width, height);
    return newFrame;
}

CGRect CGRectAddHeightToRect(CGRect rect, CGFloat delta) {
    
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height + delta);
    
    return newRect;
}

CGSize CGSizeAddHeightToSize(CGSize size, CGFloat delta) {
    CGSize newSize = CGSizeMake(size.width, size.height + delta);
    return newSize;
}

CGSize CGSizeMakeFromRect(CGRect rect) {
    CGSize newSize =  CGSizeMake(rect.size.width, rect.size.height);
    return newSize;
}
