#import "vRack.h"
#import "StorageRack.h"
@implementation vRack

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
        [NSBundle loadNibNamed:@"vRack" owner:self];
	[self addModule];
    return self;
}

- (void)addModule{
	
	StorageRack *elemento = [[StorageRack alloc] init];
	StorageRack *elemento1 = [[StorageRack alloc] init];
	StorageRack *elemento3 = [[StorageRack alloc] init];

	[rackModules addObject:[elemento getView]];
	[rackModules addObject:[elemento1 getView]];
	[rackModules addObject:[elemento3 getView]];


	NSLog(@"Get player stats");
	//
	//
}


@end
