#import "StorageRack.h"

@implementation StorageRack

//-------------------------------------
// return theView so it can be loaded
//-------------------------------------
-(NSView *)getView {
    return theView;
} // getView

//-------------------------------------
// initialize the controller instance
//-------------------------------------
-(id)init {
    if ([super init])
        [NSBundle loadNibNamed:@"vDrive" owner:self];
    return self;
}

- (IBAction)buttonHandler:(id)sender {
	NSLog(@"Get player stats");
	//
	//
	(void)sender;
}


@end
