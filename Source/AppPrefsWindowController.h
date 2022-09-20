//
//  AppPrefsWindowController.h
//


#import <Cocoa/Cocoa.h>
#import "ToolbarWindowController.h"
#import "ContactsController.h"
#import "StorageRack.h"
#import "vRack.h"
#import "StringUtils.h"

@interface AppPrefsWindowController : ToolbarWindowController {
	
    IBOutlet NSView *logoutPreferenceView;
	IBOutlet NSView *backgroundPreferenceView;
	IBOutlet NSView *generalPreferenceView;
	IBOutlet NSView *playbackPreferenceView;
	IBOutlet NSView *updatesPreferenceView;
	IBOutlet NSView *advancedPreferenceView;
	IBOutlet NSView *loginPreferenceView;
	IBOutlet NSView *registerPreferenceView;
	IBOutlet NSView *tokensPreferenceView;


	//Machine Registration Outlets
	IBOutlet NSTextField *RegistrationMessage;
	IBOutlet id adminname;
	IBOutlet id adminpasswd;
	
	// Login Panel Outlets
	IBOutlet NSTextField *LoginStatusMessage;
    IBOutlet id username;
    IBOutlet id passwd;
	IBOutlet id provider;	

	//Logout Outlets
	IBOutlet NSTextField *LogoutMessage;
	IBOutlet id uname;
    IBOutlet id pswd;
	IBOutlet id theprovider;	
	
	StorageRack *storageObj;
	IBOutlet NSArrayController *storModules;
	

	//Properties 
	IBOutlet NSTextField  *masterRegistry;
	IBOutlet NSTextField  *localRegistry;
	IBOutlet NSTextField  *providerID;
	IBOutlet NSTextField  *propertiesMessage;
	IBOutlet NSTextField  *email;

	//Properties 
	IBOutlet NSTextField  *TokenStatusMessage;
	IBOutlet NSTextField  *deviceToken;
	
	// Dummy Buttons to compile for now
	IBOutlet id CloudifyModeButton; 
	IBOutlet id VoyagerModeButton; 
	IBOutlet id HideUserButton; 


}

- (IBAction)addModule:(id)sender;
- (IBAction)loginRequest:(id)sender;
- (IBAction)logoutRequest:(id)sender;
- (IBAction)registerMachine:(id)sender;
- (IBAction)configProperties:(id)sender;
- (IBAction)fetchProperties:(id)sender;
- (IBAction)machTokenRequest:(id)sender;
- (IBAction)tokenRequest:(id)sender;

- (NSString *)registerMachineInfo:(NSString *) token:(NSString *) custid:(NSString *) dcspURL:(NSString *) dclocURL:(NSString *) adminuser:(NSString *) adminpassword:(NSString *) pin;
- (NSString *)requestMachineToken:(NSString *) token:(NSString *) custid:(NSString *) dcspURL:(NSString *) dclocURL:(NSString *) adminuser:(NSString *) adminpassword:(NSString *) pin;
- (NSString *)makeToken:(NSString *) providerid:(NSString *) publicCloud:(NSString *) privateCloud:(NSString *) machusername:(NSString *) pswdrst:(NSString *) emailaddress;
- (BOOL) createCloudified:(NSString *) u:(NSString *) spass: (NSString *) uid: (NSString *) gid: (NSString *) adminName:(NSString *) adminPasswd;
- (BOOL) createGateway:(NSString *) u:(NSString *) spass: (NSString *) uid: (NSString *) gid: (NSString *) adminName:(NSString *) adminPasswd;

@end
