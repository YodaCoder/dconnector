/* StorageRack */

#import <Cocoa/Cocoa.h>

@interface StorageRack : NSObject
{
    IBOutlet NSTextField *dstTextField;
    IBOutlet NSTextField *srcTextField;
	IBOutlet NSTextField *StorageMessage;
    IBOutlet NSView *theView;


}
-(NSView *)getView;

- (IBAction)buttonHandler:(id)sender;

-(id)init;

@end
