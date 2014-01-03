@class Figure;
@interface ImageDownloadUtil : NSObject

+(ImageDownloadUtil *)sharedInstance;

-(void)fetchAndSaveImageForPerson:(Person *)person completion:(void(^)(UIImage *))completion;
-(void)fetchAndSaveImageForFigure:(Figure *)figure completion:(void(^)(UIImage *theImage))completion;

@end
