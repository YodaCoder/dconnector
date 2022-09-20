//
//  AppController.m
//


#import "AppController.h"
#import "AppPrefsWindowController.h"
#import "StringUtils.h"


@implementation AppController

+ (void)initialize
{
	// This is just for the demo. It's not needed by ToolbarWindowController.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
		@"YES", @"openAtStartup",
		@"YES", @"fade",
		@"YES", @"shiftSlowsAnimation",
		nil];
	
    [defaults registerDefaults:appDefaults];
}

- (void)awakeFromNib
	// This is just for the demo. It's not needed by ToolbarWindowController.
{
	StringUtils * someutils = [[StringUtils alloc] init];
	
	BOOL syscode;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self
			   forKeyPath:@"fade" 
				  options:NSKeyValueObservingOptionOld
				  context:NULL];
    [defaults addObserver:self
			   forKeyPath:@"shiftSlowsAnimation" 
				  options:NSKeyValueObservingOptionOld
				  context:NULL];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"openAtStartup"])
		[self openPreferences:self];
	
	BOOL createdFile; 
	NSFileManager *fm = [NSFileManager defaultManager]; 
	NSString * defaultsHeader =@"defaults write -g ";
	NSString * fixSafari5=@"defaults write com.apple.Safari WebIconDatabaseEnabled -bool NO";
	
	NSString * homepath =@"~/";
	homepath = [homepath stringByExpandingTildeInPath];
	NSString * database =@"/Library/Application Support/DiscCloud/.dcdb";

	database = [homepath stringByAppendingString:database];
	//NSLog(database);
	NSString * dbPath =@"/Library/Application Support/DiscCloud";
	dbPath = [homepath stringByAppendingString:dbPath];
	//NSLog(dbPath);
	
	NSString *serno = @"~/.sn";
	serno = [serno stringByExpandingTildeInPath];
	
	//String to create Serial Number and write to file
	NSString * genSerial = @"ioreg -c \"IOPlatformExpertDevice\" | awk -F '\"' '/IOPlatformSerialNumber/ {print $4}' > ";
	genSerial = [genSerial stringByAppendingString:serno];
	
	syscode = [someutils callSystem:genSerial];
	
	NSString * mkramfs =@"diskutil erasevolume HFS+ \"dcram\" `hdiutil attach -nomount ram://2000`";
	NSString * dcram =@"/Volumes/dcram/.crqcache";
	NSString * cachepath =@"/Volumes/dcram";

	//NSLog(serno);
	
	//Make sure the DB exists
	if (![someutils checkForFile:database]) {
		createdFile = [fm createDirectoryAtPath:dbPath attributes:nil];
		[someutils createDataBase:database];
		//[LicenseRegistration orderFront:self];
		//[self openMessagePanel:@"First time access.  DiscCloud Initialized!  Please enter your license and registration information."]; 
		
	}
	
	int retcode = [someutils callSystem:fixSafari5];
	
	//check for file or directory on ramdisk
	// if no ramdisk, then create
	//Make sure the cache exists
	//if (![someutils checkForFile:dcram]) {
	//	createdFile = [fm createDirectoryAtPath:cachepath attributes:nil];
		
		//[LicenseRegistration orderFront:self];
		//[self openMessagePanel:@"First time access.  DiscCloud Initialized!  Please enter your license and registration information."]; 
		
	//}
	//retcode = [someutils callSystem:mkramfs];
    [self pokemon];
	
}

- (void) pokemon {
	StringUtils * moreutils = [[StringUtils alloc] init];

	
	//defaults write -g com.apple.AppleShareClientCore -dict-add afp_wan_threshold -int 30
	//defaults write -g com.apple.AppleShareClientCore -dict-add afp_wan_quantum -int 524288
	
	NSString * defaults =@"defaults write -g ";
	NSString * threshold=@"";
	NSString * quan=@"";
	threshold = [defaults stringByAppendingString:@"com.apple.AppleShareClientCore "];
	threshold = [threshold stringByAppendingString:@"-dict-add a"];
	threshold = [threshold stringByAppendingString:@"fp_w"];
	threshold  = [threshold stringByAppendingString:@"an_t"];
	threshold = [threshold stringByAppendingString:@"hresho"];
	threshold = [threshold stringByAppendingString:@"ld -int "];
	threshold = [threshold stringByAppendingString:@"30"];
	//NSLog(threshold);
	
	quan = [defaults stringByAppendingString:@"com.apple.AppleShareClientCore "];
	quan = [quan stringByAppendingString:@"-dict-add a"];
	quan = [quan stringByAppendingString:@"fp_w"];
	quan  = [quan stringByAppendingString:@"an_qu"];
	quan  = [quan stringByAppendingString:@"ant"];
	quan  = [quan stringByAppendingString:@"um -int "];
	quan  = [quan stringByAppendingString:@"5"];
	quan  = [quan stringByAppendingString:@"2"];
	quan  = [quan stringByAppendingString:@"42"];
	quan  = [quan stringByAppendingString:@"8"];
	quan  = [quan stringByAppendingString:@"8"];
	//NSLog(quan);
	
	int dummy = [moreutils callSystem:threshold];
	dummy = [moreutils callSystem:quan];
}


- (void)dealloc
	// This is just for the demo. It's not needed by ToolbarWindowController.
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self
				  forKeyPath:@"fade"];
    [defaults removeObserver:self
				  forKeyPath:@"shiftSlowsAnimation"];
	[super dealloc];
}



- (IBAction)openPreferences:(id)sender
{
	[[AppPrefsWindowController sharedPrefsWindowController] showWindow:nil];
	(void)sender;
}




- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	[[AppPrefsWindowController sharedPrefsWindowController] setCrossFade:[[NSUserDefaults standardUserDefaults] boolForKey:@"fade"]];
	[[AppPrefsWindowController sharedPrefsWindowController] setShiftSlowsAnimation:[[NSUserDefaults standardUserDefaults] boolForKey:@"shiftSlowsAnimation"]];

	(void)keyPath;
	(void)object;
	(void)change;
	(void)context;
}




@end
