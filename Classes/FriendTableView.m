#import "FriendTableView.h"
#import "FriendTableViewDelegate.h"

@implementation FriendTableView {
    
    id tableDelegate;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        tableDelegate = [[FriendTableViewDelegate alloc] init];
        self.delegate = tableDelegate;
        self.dataSource = tableDelegate;
    }
    return self;
}
-(UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
