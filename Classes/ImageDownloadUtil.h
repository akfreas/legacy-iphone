@class Figure;
@interface ImageDownloadUtil : NSObject

+(ImageDownloadUtil *)sharedInstance;


-(void)fetchAndSaveImageForFigure:(Figure *)figure completion:(void(^)(UIImage *theImage))completion;

@end
