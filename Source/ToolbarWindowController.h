//
//  ToolbarWindowController.h
//
//
//


#import <Cocoa/Cocoa.h>


@interface ToolbarWindowController : NSWindowController {
	NSMutableArray *toolbarIdentifiers;
	NSMutableDictionary *toolbarViews;
	NSMutableDictionary *toolbarItems;
	
	BOOL _crossFade;
	BOOL _shiftSlowsAnimation;
	
	NSView *contentSubview;
	NSViewAnimation *viewAnimation;
}


+ (ToolbarWindowController *)sharedPrefsWindowController;
+ (NSString *)nibName;

- (void)setupToolbar;
- (void)addView:(NSView *)view label:(NSString *)label;
- (void)addView:(NSView *)view label:(NSString *)label image:(NSImage *)image;

- (BOOL)crossFade;
- (void)setCrossFade:(BOOL)fade;
- (BOOL)shiftSlowsAnimation;
- (void)setShiftSlowsAnimation:(BOOL)slows;

- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate;
- (void)crossFadeView:(NSView *)oldView withView:(NSView *)newView;
- (NSRect)frameForView:(NSView *)view;


@end
