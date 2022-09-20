/* vRack */

#import <Cocoa/Cocoa.h>

@interface vRack : NSObject
{

    IBOutlet NSView *theView;
	IBOutlet NSArrayController *rackModules;

}
-(NSView *)getView;

- (void)addModule;

-(id)init;

@end
