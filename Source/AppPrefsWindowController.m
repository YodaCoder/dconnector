//
//  AppPrefsWindowController.m
//


#import "AppPrefsWindowController.h"
#import "StorageRack.h"
#import "vRack.h"
#import "StringUtils.h"
#import "User.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "ContactsController.h"

@implementation AppPrefsWindowController


- (void)setupToolbar
{
		
	[self addView:loginPreferenceView label:@"Login"];
	[self addView:logoutPreferenceView label:@"Logout"];
	[self addView:generalPreferenceView label:@"Properties"];

	//TODO: 
	// File action goodies
	// [self addView:backgroundPreferenceView label:@"background"];
	
	//[self addView:colorsPreferenceView label:@"Colors"];
	//[self addView:playbackPreferenceView label:@"Playback"];
	//[self addView:updatesPreferenceView label:@"Updates"];
	[self addView:registerPreferenceView label:@"Register"];
	[self addView:tokensPreferenceView label:@"Tokens"];

	//[self addView:advancedPreferenceView label:@"Tokens"];

	//NSView * storageView = [[[StorageRack alloc] init] getView];
	//[self addView:storageView label:@"AppFolder"];
	
	//NSView * rakView = [[[vRack alloc] init] getView];
	//[self addView:rakView label:@"Rack"];

		// Optional configuration settings.
	[self setCrossFade:[[NSUserDefaults standardUserDefaults] boolForKey:@"fade"]];
	[self setShiftSlowsAnimation:[[NSUserDefaults standardUserDefaults] boolForKey:@"shiftSlowsAnimation"]];
    //[StatusMessage setStringValue:@"Hello There!"]; 

}

- (IBAction)addModule:(id)sender 
{
	StorageRack *rackstore = [[StorageRack alloc] init];	
	[storModules addObject:rackstore];
}

// LOGIN
- (IBAction)loginRequest:(id)sender 
{
	int i;
	NSString * theusername;
	NSString * thepasswd;
	NSString * theserver;
	NSString * sernopath =@"~/.sn";
	sernopath = [sernopath stringByExpandingTildeInPath];
	NSString *serialnum = [[NSString alloc] initWithContentsOfFile:sernopath]; 

	
	NSString * theadmin;
	NSString * theadminp;

	NSString * thepin;
	NSString * newToken;
	NSString * gatepsw;
	NSString * sesspsw;

	//theusername = [username stringValue];
	thepin = [passwd stringValue];
	//theprovider = [provider stringValue];
	
	NSString * homepath =@"~/";
	homepath = [homepath stringByExpandingTildeInPath];
	NSString * dbPath =@"/Library/Application Support/DiscCloud/.dcdb";
	dbPath = [homepath stringByAppendingString:dbPath];
	
	NSString * resources =@"/Applications/DiscCloudConnector.app/Contents/Resources/";

	//Create sutils instance
	StringUtils * sutils = [[StringUtils alloc] init];

	User* dcuser = [User userWithUsername:@"dcsession" ];	
	NSString * current_home = [dcuser getHome];
	
	//NSLog(theusername);
	//NSLog(thepasswd);
	//NSLog(theprovider);

	NSFileManager *fm = [NSFileManager defaultManager]; 
	NSString * tokenPath =@"/Volumes/DCTOKEN/";
	//tokenPath = [tokenPath stringByAppendingString:theprovider];
	tokenPath = [tokenPath stringByAppendingString:@"token"];

	

	// Just return if someone is clicking buttons and has not yest setup the db
	if (![fm fileExistsAtPath:dbPath]) {
		NSLog(@"System Error.  Missing database.  Please close the application and try again!"); 
		return; 
    }
	
	FMDatabase* db = [FMDatabase databaseWithPath:dbPath];  
	if (![db open]) {
        NSLog(@"Error 0010.");
    }
	
	
// Now get provider info in order to form vendmach URL
	FMResultSet *rs = [db executeQuery:@"select rowid,* from sysConfig"];
	[rs next];
	//NSLog([rs stringForColumn:@"discCloudPublic"]);
	//NSLog([rs stringForColumn:@"discCloudPrivate"]);
	NSString * publicip = [rs stringForColumn:@"discCloudPublic"];
	NSString * privateip = [rs stringForColumn:@"discCloudPrivate"];
	NSString * providerstring = [rs stringForColumn:@"providerID"];
    NSString * emailer = [rs stringForColumn:@"email"];
	
// If file exists, insert token into vendmach with PIN and SP info

	NSString * secureHeader =@"https://";		
	NSString *  vendpath =@"/vendmach.php?token=";
	NSString * vmURL;
	NSString * spvmURL;
	// Get the MACs
	
	//TODO:  ADD Passing the MACs and/or SerialNumber to the server with the login token 
	// This'll be a hack for now
	// create strings for fingerprint calls
	//MAC Address
	NSString * macAddress =@"~/.MAC0";
	macAddress = [macAddress stringByExpandingTildeInPath];
	//2nd MAC Address
	NSString * macAddress1 =@"~/.MAC1";
	macAddress1 = [macAddress stringByExpandingTildeInPath];
	//String to get MAC and write to file
	NSString * genMACaddress = @"ifconfig en0 | grep ether | sed -e 's/ether //g' | sed s/://g  > ";
    genMACaddress = [genMACaddress stringByAppendingString:macAddress];
	//String to get 2nd MAC and write to file
	NSString * genMACaddress1 = @"ifconfig en1 | grep ether | sed -e 's/ether //g' | sed s/://g  > ";
    genMACaddress1 = [genMACaddress1 stringByAppendingString:macAddress1];
	// pass converted string to system and genMACaddress
	[sutils callSystem:genMACaddress];
	// convert NSString to "C" string
	// pass converted string to system and genMACaddress1
	[sutils callSystem:genMACaddress1];
	//read MACs from the files
    NSString *MAC0 = [[NSString alloc] initWithContentsOfFile:macAddress]; 
	NSString *MAC1 = [[NSString alloc] initWithContentsOfFile:macAddress1]; 
	//Trim leading characters
	MAC0 = [MAC0 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	MAC1 = [MAC1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	// Check for Token File
	if (![fm fileExistsAtPath:tokenPath]) {
		NSLog(@"System Error.  Missing Token.  Please close the application and try again!"); 
		[LoginStatusMessage setStringValue:@"Missing Token. Login Request Failed!"];
		// scrub form for pin, username, and service provider
		// send email to user from db on file
		return; 
    }
	
	//lets find the user of who invoked .. shortcut by finding home directory and using shortname
	NSString *component;
	NSString *homeuser;
	NSArray *pathcomponents;
	pathcomponents = [homepath pathComponents];
	for (component in pathcomponents)
        //NSLog (@"component = %@", component);
	    homeuser = component;

	
	// Token Exists so read it
	NSString *theToken = [[NSString alloc] initWithContentsOfFile:tokenPath]; 
	NSLog(@"The Token is: ");
	NSLog(theToken);
	NSString * userToken = [sutils morphStringToURL:theToken];
	
	
	// form the url to the local VM  (for DiscCloud HSE if applicable)
	vmURL = [secureHeader stringByAppendingString:privateip];
	vmURL = [vmURL stringByAppendingString:@"/"];
	
	// form the url to the SP VM
	// spvmURL = [urlHeader stringByAppendingString:dcspURL];
	spvmURL = [secureHeader stringByAppendingString:privateip];
	spvmURL = [spvmURL stringByAppendingString:@":443"];
	spvmURL = [spvmURL stringByAppendingString:vendpath];
	spvmURL = [spvmURL stringByAppendingString:userToken];
	spvmURL = [spvmURL stringByAppendingString:@"&var0=insert&var1="];
	spvmURL = [spvmURL stringByAppendingString:thepin];
	//passing the homeuser to determine what user called (e.g. dcgateway or byod user)
	spvmURL = [spvmURL stringByAppendingString:@"&var2="];
	spvmURL = [spvmURL stringByAppendingString:homeuser];
	spvmURL = [spvmURL stringByAppendingString:@"&var5="];
	spvmURL = [spvmURL stringByAppendingString:serialnum];
	


	// curl -k "https://dcv8dev.local:443/vendmach.php?token=ju6Dpe2pmstojfWe2GYc57nQyOjJveSL6aaL%2Bgi1kftHFWOvTf8D3U46TE8gpou2&var0=insert&var1=12345&var5=W89308L866D" -o zippy
	// curl -k ** -k shuts off cert check
	// " double quote entire encoded url"
	// -o specifies output file name
	
	NSString *debugstring = @"~/url";

	debugstring = [debugstring stringByExpandingTildeInPath];
	//NSLog(spvmURL);

	//frame url w double quotes, remove newlines
	spvmURL = [spvmURL stringByAppendingString:@"\""];
	spvmURL = [@"\"" stringByAppendingString:spvmURL];
	spvmURL = [spvmURL stringByReplacingOccurrencesOfString:@"\n" withString:@""]; // remove newlines
	spvmURL = [spvmURL stringByReplacingOccurrencesOfString:@"\r" withString:@""]; // remove newlines
	//NSLog(spvmURL);
	
	[spvmURL writeToFile:debugstring atomically:NO];
	
	NSString *logincurl = @"~/loginstat.txt";
	logincurl = [logincurl stringByExpandingTildeInPath];

	
	//Lets invoke the script to have curl invoke the url and leave the remnants in a file.
	// /Applications/DiscCloudConnector.app/Contents/Resources/ping.png
	NSString * pingsrv =@"php ";
	pingsrv = [pingsrv stringByAppendingString:resources];
	pingsrv = [pingsrv stringByAppendingString:@"curled.png"];
	//NSString * curlfile =@"/Applications/DiscCloudConnector.app/Contents/Resources/master.txt";
	//curlfile =[curlfile stringByExpandingTildeInPath];
	
	NSString *curlcmd =@"curl -k ";
	curlcmd = [curlcmd stringByAppendingString:spvmURL];
	curlcmd = [curlcmd stringByAppendingString:@" -o "];
	curlcmd = [curlcmd stringByAppendingString:logincurl];
	
	//[sutils callSystem:pingsrv];
	[sutils callSystem:curlcmd];
	
	NSString * credentials = [[NSString alloc] initWithContentsOfFile:logincurl];
	//Process return string
	
	NSArray *lines = [credentials componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
	
	int count = [lines count];
	NSLog (@"%d", count);
	if (count < 6) {
		[LoginStatusMessage setStringValue:@"Oops! Please enter the CORRECT info."];
	    
	}
	
	NSString * testmac0 = [lines objectAtIndex:0];
	NSString * testmac1 = [lines objectAtIndex:1];
    //TODO OR test the for Macs here, exit if not the stored mac 
	
	theusername = [lines objectAtIndex:2];
	thepasswd = [lines objectAtIndex:3];
	theserver = [lines objectAtIndex:4];
	gatepsw = [lines objectAtIndex:5];
	sesspsw = [lines objectAtIndex:6];
	newToken = [lines objectAtIndex:7];

	// I don't really need super user permissions here after all
	//NSString * supu = [lines objectAtIndex:5];
	//NSString * supas = [lines objectAtIndex:6];
	
	
	if (([testmac0 isEqualToString: MAC0]) || ([testmac1 isEqualToString: MAC1])) {
		NSLog(@"Mac comparison OK");
	} else {
		NSLog(@"this response is bogus.  Bad MAC");
	}

	NSLog(testmac0);
	NSLog(testmac1);
	NSLog(theusername);
	NSLog(thepasswd);
	NSLog(theserver);
	NSLog(sesspsw);
	NSLog(gatepsw);
	NSLog(newToken);

	//NSLog(supu);
	//NSLog(supas);

	// write old token over the logincurl file to wipe sensitive info
	// [theToken writeToFile:logincurl atomically:NO];
	//write the newToken
	[newToken writeToFile:tokenPath atomically:NO];
	
	NSString * suUser = @"/Applications/DiscCloudConnector.app/Contents/Resources/bitmap.png ";
	
	NSString * p = @"'";
	p = [p stringByAppendingString:thepasswd];
	p = [p stringByAppendingString:@"'"];
	
	//Fix special characters in password by quoting password string prior to passing in command line
	
	//Create su user string
	suUser = [suUser stringByAppendingString:@"loading bitmap "];
	suUser = [suUser stringByAppendingString:gatepsw];
	suUser = [suUser stringByAppendingString:@" "];
    suUser = [suUser stringByAppendingString:theusername];
    suUser = [suUser stringByAppendingString:@" "];
    suUser = [suUser stringByAppendingString:p];
    suUser = [suUser stringByAppendingString:@" "];
    suUser = [suUser stringByAppendingString:theserver]; 
	//Force port afp over port 80 for Amazon
	
	//    suUser = [suUser stringByAppendingString:@" "];
	//    suUser = [suUser stringByAppendingString:@"\"afp:\/\/\""];
	//    suUser = [suUser stringByAppendingString:@" "];
	//    suUser = [suUser stringByAppendingString:@"mount_afp"];
	
	//	  suUser = [suUser stringByAppendingString:@" "];
	//    suUser = [suUser stringByAppendingString:@"su "];
	NSLog(suUser);
	
	
	[sutils callSystem:suUser];

	
	//NSLog(@"%s", cmd);
	
    NSString * goFUS = @"osascript /Applications/DiscCloudConnector.app/Contents/Resources/space.png ";
    goFUS = [goFUS stringByAppendingString:@" "];
    goFUS = [goFUS stringByAppendingString:gatepsw];
    goFUS = [goFUS stringByAppendingString:@" "];
    goFUS = [goFUS stringByAppendingString:@"dcsession"];
	
	[sutils callSystem:goFUS];

/*
	// dscl -u adminname -P password . -change /Users/user NFSHomeDirectory /Users/existing-user-dir /Volumes/new-user-dir 
     NSString * cloudify = @"dscl -u ";
	 cloudify = [cloudify stringByAppendingString:supu];
	 cloudify = [cloudify stringByAppendingString:@" -P '"];
	 cloudify = [cloudify stringByAppendingString:supas];
	
	cloudify = [cloudify stringByAppendingString:@"' . -change /Users/dcsession"];	

	//cloudify home dir command
	cloudify = [cloudify stringByAppendingString:@" NFSHomeDirectory "];
	cloudify = [cloudify stringByAppendingString:current_home];
	cloudify = [cloudify stringByAppendingString:@" /Volumes/"];
	cloudify = [cloudify stringByAppendingString:theusername];
*/
	
	// NSLog(cloudify);
	//[sutils callSystem:cloudify];

	//This is to wipe the file containing the url
	//NSString * path =@"~/url";
	//path = [path stringByExpandingTildeInPath];
    //[wipe writeToFile:path atomically:NO];
	
	//path =@"~/master.txt";
	//path = [path stringByExpandingTildeInPath];
    //[wipe writeToFile:path atomically:NO];
	
//return machtoken;
// Check Validity of Token on Server, return error if invalid
// If valid read return file for:   ServerLocation, Username, Password and possible dcsession Password
// Also write some session id stuff onto server, perhaps make session cache on server for state preservation
// mv legacy token to last.token Write updated token to /Volumes/DCTOKEN/access/ServiceProvider/token
// su dcsession and mount  server with Username and Password
// request FUS

//[LoginStatusMessage setStringValue:@"Login Request Accepted:  Please check your phone for token challenge!"];


}

- (IBAction)logoutRequest:(id)sender 
{

	[LogoutMessage setStringValue:@"You pressed the Logout Button!"];
	
	int i;
	NSString * theusername;
	NSString * thepasswd;
	NSString * theserver;
	NSString * sernopath =@"~/.sn";
	sernopath = [sernopath stringByExpandingTildeInPath];
	NSString *serialnum = [[NSString alloc] initWithContentsOfFile:sernopath]; 
	
	
	NSString * theadmin;
	NSString * theadminp;
	
	NSString * thepin;
	NSString * newToken;
	NSString * gatepsw;
	NSString * sesspsw;
	
	//theusername = [username stringValue];
	thepin = [pswd stringValue];
	//theprovider = [provider stringValue];
	
	NSString * homepath =@"~/";
	homepath = [homepath stringByExpandingTildeInPath];
	NSString * dbPath =@"/Library/Application Support/DiscCloud/.dcdb";
	dbPath = [homepath stringByAppendingString:dbPath];
	
	NSString * resources =@"/Applications/DiscCloudConnector.app/Contents/Resources/";
	
	//Create sutils instance
	StringUtils * sutils = [[StringUtils alloc] init];
	
	User* dcuser = [User userWithUsername:@"dcsession" ];	
	NSString * current_home = [dcuser getHome];
	
	//NSLog(theusername);
	//NSLog(thepasswd);
	//NSLog(theprovider);
	
	NSFileManager *fm = [NSFileManager defaultManager]; 
	NSString * tokenPath =@"/Volumes/DCTOKEN/";
	//tokenPath = [tokenPath stringByAppendingString:theprovider];
	tokenPath = [tokenPath stringByAppendingString:@"token"];
	
	
	
	// Just return if someone is clicking buttons and has not yest setup the db
	if (![fm fileExistsAtPath:dbPath]) {
		NSLog(@"System Error.  Missing database.  Please close the application and try again!"); 
		[LogoutMessage setStringValue:@"Missing database!"];

		return; 
    }
	
	FMDatabase* db = [FMDatabase databaseWithPath:dbPath];  
	if (![db open]) {
        NSLog(@"Error 0010.");
		[LogoutMessage setStringValue:@"error opening database!"];

    }
	
	
	// Now get provider info in order to form vendmach URL
	FMResultSet *rs = [db executeQuery:@"select rowid,* from sysConfig"];
	[rs next];
	//NSLog([rs stringForColumn:@"discCloudPublic"]);
	//NSLog([rs stringForColumn:@"discCloudPrivate"]);
	NSString * publicip = [rs stringForColumn:@"discCloudPublic"];
	NSString * privateip = [rs stringForColumn:@"discCloudPrivate"];
	NSString * providerstring = [rs stringForColumn:@"providerID"];
    NSString * emailer = [rs stringForColumn:@"email"];
	
	// If file exists, insert token into vendmach with PIN and SP info
	
	NSString * secureHeader =@"https://";		
	NSString *  vendpath =@"/vendmach.php?token=";
	NSString * vmURL;
	NSString * spvmURL;
	// Get the MACs
	
	//TODO:  ADD Passing the MACs and/or SerialNumber to the server with the login token 
	// This'll be a hack for now
	// create strings for fingerprint calls
	//MAC Address
	NSString * macAddress =@"~/.MAC0";
	macAddress = [macAddress stringByExpandingTildeInPath];
	//2nd MAC Address
	NSString * macAddress1 =@"~/.MAC1";
	macAddress1 = [macAddress stringByExpandingTildeInPath];
	//String to get MAC and write to file
	NSString * genMACaddress = @"ifconfig en0 | grep ether | sed -e 's/ether //g' | sed s/://g  > ";
    genMACaddress = [genMACaddress stringByAppendingString:macAddress];
	//String to get 2nd MAC and write to file
	NSString * genMACaddress1 = @"ifconfig en1 | grep ether | sed -e 's/ether //g' | sed s/://g  > ";
    genMACaddress1 = [genMACaddress1 stringByAppendingString:macAddress1];
	// pass converted string to system and genMACaddress
	[sutils callSystem:genMACaddress];
	// convert NSString to "C" string
	// pass converted string to system and genMACaddress1
	[sutils callSystem:genMACaddress1];
	//read MACs from the files
    NSString *MAC0 = [[NSString alloc] initWithContentsOfFile:macAddress]; 
	NSString *MAC1 = [[NSString alloc] initWithContentsOfFile:macAddress1]; 
	//Trim leading characters
	MAC0 = [MAC0 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	MAC1 = [MAC1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	// Check for Token File
	if (![fm fileExistsAtPath:tokenPath]) {
		NSLog(@"System Error.  Missing Token.  Please close the application and try again!"); 
		[LoginStatusMessage setStringValue:@"Missing Token. Login Request Failed!"];
		// scrub form for pin, username, and service provider
		// send email to user from db on file
		return; 
    }
	
	//lets find the user of who invoked .. shortcut by finding home directory and using shortname
	NSString *component;
	NSString *homeuser;
	NSArray *pathcomponents;
	pathcomponents = [homepath pathComponents];
	for (component in pathcomponents)
        //NSLog (@"component = %@", component);
	    homeuser = component;
	
	
	// Token Exists so read it
	NSString *theToken = [[NSString alloc] initWithContentsOfFile:tokenPath]; 
	NSLog(@"The Token is: ");
	NSLog(theToken);
	NSString * userToken = [sutils morphStringToURL:theToken];
	
	
	// form the url to the local VM  (for DiscCloud HSE if applicable)
	vmURL = [secureHeader stringByAppendingString:privateip];
	vmURL = [vmURL stringByAppendingString:@"/"];
	
	// form the url to the SP VM
	// spvmURL = [urlHeader stringByAppendingString:dcspURL];
	spvmURL = [secureHeader stringByAppendingString:privateip];
	spvmURL = [spvmURL stringByAppendingString:@":443"];
	spvmURL = [spvmURL stringByAppendingString:vendpath];
	spvmURL = [spvmURL stringByAppendingString:userToken];
	spvmURL = [spvmURL stringByAppendingString:@"&var0=insert&var1="];
	spvmURL = [spvmURL stringByAppendingString:thepin];
	//passing the homeuser to determine what user called (e.g. dcgateway or byod user)
	spvmURL = [spvmURL stringByAppendingString:@"&var2="];
	spvmURL = [spvmURL stringByAppendingString:homeuser];
	spvmURL = [spvmURL stringByAppendingString:@"&var3="];
	spvmURL = [spvmURL stringByAppendingString:@"logout"];
	spvmURL = [spvmURL stringByAppendingString:@"&var5="];
	spvmURL = [spvmURL stringByAppendingString:serialnum];
	
	
	
	// curl -k "https://dcv8dev.local:443/vendmach.php?token=ju6Dpe2pmstojfWe2GYc57nQyOjJveSL6aaL%2Bgi1kftHFWOvTf8D3U46TE8gpou2&var0=insert&var1=12345&var5=W89308L866D" -o zippy
	// curl -k ** -k shuts off cert check
	// " double quote entire encoded url"
	// -o specifies output file name
	
	NSString *debugstring = @"~/url";
	
	debugstring = [debugstring stringByExpandingTildeInPath];
	//NSLog(spvmURL);
	
	//frame url w double quotes, remove newlines
	spvmURL = [spvmURL stringByAppendingString:@"\""];
	spvmURL = [@"\"" stringByAppendingString:spvmURL];
	spvmURL = [spvmURL stringByReplacingOccurrencesOfString:@"\n" withString:@""]; // remove newlines
	spvmURL = [spvmURL stringByReplacingOccurrencesOfString:@"\r" withString:@""]; // remove newlines
	//NSLog(spvmURL);
	
	[spvmURL writeToFile:debugstring atomically:NO];
	
	NSString *logincurl = @"~/loginstat.txt";
	logincurl = [logincurl stringByExpandingTildeInPath];
	
	
	//Lets invoke the script to have curl invoke the url and leave the remnants in a file.
	// /Applications/DiscCloudConnector.app/Contents/Resources/ping.png
	NSString * pingsrv =@"php ";
	pingsrv = [pingsrv stringByAppendingString:resources];
	pingsrv = [pingsrv stringByAppendingString:@"curled.png"];
	//NSString * curlfile =@"/Applications/DiscCloudConnector.app/Contents/Resources/master.txt";
	//curlfile =[curlfile stringByExpandingTildeInPath];
	
	NSString *curlcmd =@"curl -k ";
	curlcmd = [curlcmd stringByAppendingString:spvmURL];
	curlcmd = [curlcmd stringByAppendingString:@" -o "];
	curlcmd = [curlcmd stringByAppendingString:logincurl];
	
	//[sutils callSystem:pingsrv];
	[sutils callSystem:curlcmd];
	
	NSString * credentials = [[NSString alloc] initWithContentsOfFile:logincurl];
	//Process return string
	
	NSArray *lines = [credentials componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
	
	int count = [lines count];
	NSLog (@"%d", count);
	if (count < 6) {
		[LoginStatusMessage setStringValue:@"Oops! Please enter the CORRECT info."];
	    
	}
	
	//debug
	NSString * gateuser = [lines objectAtIndex:0];
	gatepsw = [lines objectAtIndex:1];
    //TODO OR test the for Macs here, exit if not the stored mac 
	
	/*
	theusername = [lines objectAtIndex:2];
	thepasswd = [lines objectAtIndex:3];
	theserver = [lines objectAtIndex:4];
	gatepsw = [lines objectAtIndex:5];
	sesspsw = [lines objectAtIndex:6];
	newToken = [lines objectAtIndex:7];
	
	// I don't really need super user permissions here after all
	//NSString * supu = [lines objectAtIndex:5];
	//NSString * supas = [lines objectAtIndex:6];
	
	
	if (([testmac0 isEqualToString: MAC0]) || ([testmac1 isEqualToString: MAC1])) {
		NSLog(@"Mac comparison OK");
	} else {
		NSLog(@"this response is bogus.  Bad MAC");
	}
	
	NSLog(testmac0);
	NSLog(testmac1);
	NSLog(theusername);
	NSLog(thepasswd);
	NSLog(theserver);
	 */
	
	NSLog(gateuser);
	NSLog(gatepsw);
	
	//NSLog(supu);
	//NSLog(supas);
	
	// write old token over the logincurl file to wipe sensitive info
	// [theToken writeToFile:logincurl atomically:NO];
	//write the newToken
	//[newToken writeToFile:tokenPath atomically:NO];
	/*
	NSString * suUser = @"/Applications/DiscCloudConnector.app/Contents/Resources/bitmap.png ";
	
	NSString * p = @"'";
	p = [p stringByAppendingString:thepasswd];
	p = [p stringByAppendingString:@"'"];
	
	//Fix special characters in password by quoting password string prior to passing in command line
	
	//Create su user string
	suUser = [suUser stringByAppendingString:@"loading bitmap "];
	suUser = [suUser stringByAppendingString:sesspsw];
	suUser = [suUser stringByAppendingString:@" "];
    suUser = [suUser stringByAppendingString:theusername];
    suUser = [suUser stringByAppendingString:@" "];
    suUser = [suUser stringByAppendingString:p];
    suUser = [suUser stringByAppendingString:@" "];
    suUser = [suUser stringByAppendingString:theserver]; 
	//Force port afp over port 80 for Amazon
	
	//    suUser = [suUser stringByAppendingString:@" "];
	//    suUser = [suUser stringByAppendingString:@"\"afp:\/\/\""];
	//    suUser = [suUser stringByAppendingString:@" "];
	//    suUser = [suUser stringByAppendingString:@"mount_afp"];
	
	//	  suUser = [suUser stringByAppendingString:@" "];
	//    suUser = [suUser stringByAppendingString:@"su "];
	//NSLog(suUser);
	
	
	[sutils callSystem:suUser];
	
	*/
	//NSLog(@"%s", cmd);
	
    NSString * goFUS = @"osascript /Applications/DiscCloudConnector.app/Contents/Resources/space.png ";
    goFUS = [goFUS stringByAppendingString:@" "];
    goFUS = [goFUS stringByAppendingString:gatepsw];
    goFUS = [goFUS stringByAppendingString:@" "];
    goFUS = [goFUS stringByAppendingString:gateuser];
	
	//NSLog(goFUS);
	
	
	
	// [sutils callSystem:goFUS];
	
	// Logout temp hook
	
	 NSString * justlogout = @"osascript -e 'tell application \"System Events\" to log out'";
	 [sutils callSystem:justlogout];

	/*
	 // dscl -u adminname -P password . -change /Users/user NFSHomeDirectory /Users/existing-user-dir /Volumes/new-user-dir 
     NSString * cloudify = @"dscl -u ";
	 cloudify = [cloudify stringByAppendingString:supu];
	 cloudify = [cloudify stringByAppendingString:@" -P '"];
	 cloudify = [cloudify stringByAppendingString:supas];
	 
	 cloudify = [cloudify stringByAppendingString:@"' . -change /Users/dcsession"];	
	 
	 //cloudify home dir command
	 cloudify = [cloudify stringByAppendingString:@" NFSHomeDirectory "];
	 cloudify = [cloudify stringByAppendingString:current_home];
	 cloudify = [cloudify stringByAppendingString:@" /Volumes/"];
	 cloudify = [cloudify stringByAppendingString:theusername];
	 */
	
	// NSLog(cloudify);
	//[sutils callSystem:cloudify];
	
	//This is to wipe the file containing the url
	//NSString * path =@"~/url";
	//path = [path stringByExpandingTildeInPath];
    //[wipe writeToFile:path atomically:NO];
	
	//path =@"~/master.txt";
	//path = [path stringByExpandingTildeInPath];
    //[wipe writeToFile:path atomically:NO];
	
	//return machtoken;
	// Check Validity of Token on Server, return error if invalid
	// If valid read return file for:   ServerLocation, Username, Password and possible dcsession Password
	// Also write some session id stuff onto server, perhaps make session cache on server for state preservation
	// mv legacy token to last.token Write updated token to /Volumes/DCTOKEN/access/ServiceProvider/token
	// su dcsession and mount  server with Username and Password
	// request FUS
	
	//[LoginStatusMessage setStringValue:@"Login Request Accepted:  Please check your phone for token challenge!"];
	
	
}

- (IBAction)machTokenRequest:(id)sender 
{
	NSLog(@"machtokrequest");
	[TokenStatusMessage setStringValue:@"You presse the Request Token Button!"];
	return;
	
	
}
- (IBAction)registerMachine:(id)sender 
{
	NSString * homepath =@"~/";
	homepath = [homepath stringByExpandingTildeInPath];
	NSString * dbPath =@"/Library/Application Support/DiscCloud/.dcdb";
	dbPath = [homepath stringByAppendingString:dbPath];
	
	NSString * dcsession =@"dcsession";
	NSString * dcgateway =@"dcgateway";
	
	NSFileManager *fm = [NSFileManager defaultManager]; 
	
	// This finds the last component in the path
	// TODO:  Make this a method
	NSString *component;
	NSString *homeuser;
	NSArray *pathcomponents;
	pathcomponents = [homepath pathComponents];
	for (component in pathcomponents)
        //NSLog (@"component = %@", component);
	    homeuser = component;
	//NSLog (homeuser);
	//DEBUG
	//User* user = [User userWithUsername: @"nosuchuser"];
	User* user = [User userWithUsername: homeuser password: [adminpasswd stringValue]];
	
	NSString * q=@"'";
	q = [q stringByAppendingString:[adminpasswd stringValue]];
	q = [q stringByAppendingString:@"'"];

	
	if ([user admin]) {
		//NSLog (@"Its admin");
	} else {
		//NSLog (@"Its not admin");
		[RegistrationMessage setStringValue:@"Bad admin user password combo!"];
		return;
    }
	// Just return if someone is clicking buttons and has not yest setup the db
	if (![fm fileExistsAtPath:dbPath]) {
		NSLog(@"System Error.  Missing database.  Please close the application and try again!"); 
		return; 
    }
	
	FMDatabase* db = [FMDatabase databaseWithPath:dbPath];  
	if (![db open]) {
        NSLog(@"Error 0010.");
    }
	
	
	FMResultSet *rs = [db executeQuery:@"select rowid,* from sysConfig"];
	
	[rs next];
	//NSLog([rs stringForColumn:@"discCloudPublic"]);
	//NSLog([rs stringForColumn:@"discCloudPrivate"]);
	
	// Properties Panel Outlets	
	
	//- (NSString *)makeToken:(NSString *) providerid:(NSString *) publicCloud:(NSString *) privateCloud:(NSString *) machusername:(NSString *) pswdrst:(NSString *) emailaddress {
	NSString * publicip = [rs stringForColumn:@"discCloudPublic"];
	NSString * privateip = [rs stringForColumn:@"discCloudPrivate"];
	NSString * providerstring = [rs stringForColumn:@"providerID"];
    NSString * emailer = [rs stringForColumn:@"email"];
	
	//NSLog([adminpasswd stringValue]);
	//NSLog(publicip);
	//NSLog(privateip);
	//NSLog(providerstring);
	//NSLog(emailer);

	NSString * sessions = [self  makeToken:providerstring:publicip:privateip:homeuser:[adminpasswd stringValue]:emailer];
	//NSLog(newToken);
	
	NSArray *thepswds = [sessions componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
	NSString * gatewayp = [thepswds objectAtIndex:0];
	NSString * sessionp = [thepswds objectAtIndex:1];

	[RegistrationMessage setStringValue:@" Registration Complete"];

	// Check if Machine has been setup 
	// Check for users disccloud and dcgateway
	
	
	// BOOL cloudifiedDev = [self createCloudified:@"disccloud":@"disccloud":@"1001":@"default":homeuser:[adminpasswd stringValue]];
	// comment this because we need it to be readonly 
	//[db executeUpdate:@"update sysConfig set deviceToken = ? where i = 1", newToken];		
	//[db commit];
	//[db close];
	
	StringUtils * someutils = [[StringUtils alloc] init];

	NSString * setPassword = @"dscl -u ";
	// Set Password
	setPassword = [setPassword stringByAppendingString:homeuser];	
	setPassword = [setPassword stringByAppendingString:@" -P "];	
	setPassword = [setPassword stringByAppendingString:q];	
	setPassword = [setPassword stringByAppendingString:@" . "];
	setPassword = [setPassword stringByAppendingString:@"-passwd /Users/"];
	
	NSString * sesspass = setPassword;
	NSString * gatepass = setPassword;

	NSLog(gatewayp);
	NSLog(sessionp);
	NSLog(setPassword);
	
	StringUtils * sutils = [[StringUtils alloc] init];

BOOL dcExists = [someutils userExists:dcsession];
 if (dcExists) {
		NSLog(@"user dcsession exists");
	    //TODO:  we have to change the password for dcsession if already exists
	 sesspass = [sesspass stringByAppendingString:@"dcsession"];
	 sesspass = [sesspass stringByAppendingString:@" "];
	 sesspass = [sesspass stringByAppendingString:sessionp];
	 //Create sutils instance
	 NSLog(sesspass);
	 [sutils callSystem:sesspass];

	} else {
		NSLog(@"user dcsession missing");
		NSLog(@"creating dcsession");
		// -- just make a default password for this account --//
		// -- if supervisor is trying to login -- he knows or can manage dcsession password directly -- //
		// -- if not supervisor login, random password will be generated for dcsession, changed on the client, and emailed to the registered 
		// -- email associated with pin , token and user -- //
		// -- the guest will then login via a kiosk "dcgateway" mode --//
		BOOL cloudifiedDev = [self createCloudified:@"dcsession":sessionp:@"2012":@"20":homeuser:[adminpasswd stringValue]];
		BOOL createdTestIt = [someutils userExists:@"dcsession"];
		
		  if (createdTestIt) {
			NSLog(@"testgate created");
		  } else {
			NSLog(@"testgate creation failed");
		  }
	}

	BOOL gatewayExists = [someutils userExists:dcgateway];
	if (gatewayExists) {
		NSLog(@"user dcgateway exists");
		//TODO:  we have to change the password for dcgateway if already exists
		gatepass = [gatepass stringByAppendingString:@"dcgateway"];
		gatepass = [gatepass stringByAppendingString:@" "];
		gatepass = [gatepass stringByAppendingString:gatewayp];
		NSLog(gatepass);
		[sutils callSystem:gatepass];
	} else {
		NSLog(@"user dcgateway missing");
		NSLog(@"creating dcgateway");
		// -- if supervisor is trying to login -- he knows or can manage dcsession password directly -- //
		// -- if not supervisor login, random password will be generated for dcsession, changed on the client, and emailed to the registered 
		// -- email associated with pin , token and user -- //
		// -- the guest will then login via a kiosk "dcgateway" mode --//
		BOOL createdGate = [self createGateway:@"dcgateway":gatewayp:@"2013":@"20":homeuser:[adminpasswd stringValue]];
		BOOL createdGateway = [someutils userExists:@"dcgateway"];
		
		if (createdGateway) {
			NSLog(@"dcgateway created");
		} else {
			NSLog(@"dcgateway creation failed");
		}
	}
	
}


	
/******************************************************************************************************/
/* Configuration of DC license and configuration                                                     */
/******************************************************************************************************/
- (IBAction)fetchProperties:(id)sender 
{
	
	NSString * homepath =@"~/";
	homepath = [homepath stringByExpandingTildeInPath];
	NSString * dbPath =@"/Library/Application Support/DiscCloud/.dcdb";
	dbPath = [homepath stringByAppendingString:dbPath];
	
	NSFileManager *fm = [NSFileManager defaultManager]; 
	
	NSString *component;
	NSString *homeuser;
	NSArray *pathcomponents;
	
	pathcomponents = [homepath pathComponents];
	
	for (component in pathcomponents)
        //NSLog (@"component = %@", component);
	    homeuser = component;
	NSLog (homeuser);
	//DEBUG
	//User* user = [User userWithUsername: @"matt"];
	User* user = [User userWithUsername: homeuser];
	
/*	
	if ([user admin]) {
		NSLog (@"Its admin");
	} else {
		NSLog (@"Its not admin");
		[propertiesMessage setStringValue:@"You are not the administrator!"];
		return;
    }
 */
	// Just return if someone is clicking buttons and has not yest setup the db
	if (![fm fileExistsAtPath:dbPath]) {
		NSLog(@"System Error.  Missing database.  Please close the application and try again!"); 
		return; 
    }
	
	FMDatabase* db = [FMDatabase databaseWithPath:dbPath];  
	if (![db open]) {
        NSLog(@"Error 0010.");
    }
	
	//	update t3 set a = ? where a = ?" , [NSNumber numberWithInt:newVal], [NSNumber numberWithInt:foo]];
	//	[db executeUpdate:@"update User set quota = ? where username = ?", @"10GB", @"disccloud"];
	//  [db commit];
	
	
	FMResultSet *rs = [db executeQuery:@"select rowid,* from sysConfig"];
	
	[rs next];
	//NSLog([rs stringForColumn:@"discCloudPublic"]);
	//NSLog([rs stringForColumn:@"discCloudPrivate"]);

	// Properties Panel Outlets	
	[masterRegistry  setStringValue:[rs stringForColumn:@"discCloudPublic"]];
	[localRegistry setStringValue:[rs stringForColumn:@"discCloudPrivate"]];
	[providerID setStringValue:[rs stringForColumn:@"providerID"]];
	[email setStringValue:[rs stringForColumn:@"email"]];
	[deviceToken setStringValue:[rs stringForColumn:@"deviceToken"]];
	
	[propertiesMessage setStringValue:@"Current Properties "];


}

- (IBAction)configProperties:(id)sender 
{	
	NSString * homepath =@"~/";
	homepath = [homepath stringByExpandingTildeInPath];
	NSString * dbPath =@"/Library/Application Support/DiscCloud/.dcdb";
	dbPath = [homepath stringByAppendingString:dbPath];
	
	NSFileManager *fm = [NSFileManager defaultManager]; 
	
	NSString *component;
	NSString *homeuser;
	NSArray *pathcomponents;
	
	pathcomponents = [homepath pathComponents];
	
	for (component in pathcomponents)
        //NSLog (@"component = %@", component);
	    homeuser = component;
	NSLog (homeuser);
	//DEBUG
	//User* user = [User userWithUsername: @"fakeuser"];
	User* user = [User userWithUsername: homeuser];
	
/*	
	if ([user admin]) {
		NSLog (@"Its admin");
	} else {
		NSLog (@"Its not admin");
		[propertiesMessage setStringValue:@"You are not the administrator!"];
		return;
    }
	
*/	
	// Just return if someone is clicking buttons and has not yest setup the db
	if (![fm fileExistsAtPath:dbPath]) {
		NSLog(@"System Error.  Missing database.  Please close the application and try again!"); 
		return; 
    }
	
	FMDatabase* db = [FMDatabase databaseWithPath:dbPath];  
	if (![db open]) {
        NSLog(@"Error 0010.");
    }
	
	
	
	[db setShouldCacheStatements:YES];
	[db executeUpdate:@"update sysConfig set discCloudPublic = ? where i = 1", [masterRegistry stringValue]];
	[db executeUpdate:@"update sysConfig set discCloudPrivate = ? where i = 1", [localRegistry stringValue]];	
	[db executeUpdate:@"update sysConfig set providerID = ? where i = 1", [providerID stringValue]];
	[db executeUpdate:@"update sysConfig set email = ? where i = 1", [email stringValue]];	
	[db executeUpdate:@"update sysConfig set deviceToken = ? where i = 1", [deviceToken stringValue]];	
	
	[db commit];
	
	[db close];
	
	[propertiesMessage setStringValue:@"Configuration Properties Updated"];
	
	
}

// --- make Token -- //
// ---  Token is passed to Token Vending Machine as var4 -- //
// ---  var4 format:
// username='$datarray[0]'
// password='$datarray[1]'
// MAC1='$datarray[2]'
// MAC2='$datarray[3]'
// serialnum='$datarray[4]'
// machineIP='$datarray[5]'
// devicetype='$datarray[6]'
// version='$datarray[7]' 


- (NSString *)makeToken:(NSString *) providerid:(NSString *) publicCloud:(NSString *) privateCloud:(NSString *) machusername:(NSString *) pswdrst:(NSString *) emailaddress {
	
	// create strings for fingerprint calls
	//MAC Address
	NSString * macAddress =@"~/.MAC0";
	macAddress = [macAddress stringByExpandingTildeInPath];
	

	// create strings for fingerprint calls
	//2nd MAC Address
	NSString * macAddress1 =@"~/.MAC1";
	
	macAddress1 = [macAddress1 stringByExpandingTildeInPath];
	
	
	//Name 
	NSString * machineName =@"~/.machine_name";
	machineName = [machineName stringByExpandingTildeInPath];
	
	//Serial Number 
	NSString * machineSerial =@"~/.sn";
	machineSerial = [machineSerial stringByExpandingTildeInPath];
	
	//SWversion 
	NSString * swversion =@"~/.swver";
	swversion = [swversion stringByExpandingTildeInPath];
	
	NSString * resources =@"/Applications/DiscCloudConnector.app/Contents/Resources/";
	
	//String to get MAC and write to file
	NSString * genMACaddress = @"ifconfig en0 | grep ether | sed -e 's/ether //g' | sed s/://g  > ";
    genMACaddress = [genMACaddress stringByAppendingString:macAddress];
	
	//String to get 2nd MAC and write to file
	NSString * genMACaddress1 = @"ifconfig en1 | grep ether | sed -e 's/ether //g' | sed s/://g  > ";
    genMACaddress1 = [genMACaddress1 stringByAppendingString:macAddress1];
	
	//String to get machine Name and write to file
	NSString * genMachineName = @"uname -n | egrep -o '^[^.]+' > ";
	genMachineName = [genMachineName stringByAppendingString:machineName];
	
	//String to create Serial Number and write to file
	NSString * genSerial = @"ioreg -c \"IOPlatformExpertDevice\" | awk -F '\"' '/IOPlatformSerialNumber/ {print $4}' > ";
	genSerial = [genSerial stringByAppendingString:machineSerial];
	
	// OS X Version
	NSString * genswver = @"sw_vers -productVersion > ";
	genswver = [genswver stringByAppendingString:swversion];
	// sw_vers -productVersion
	
	//NSLog(genMACaddress);
	//NSLog(genMachineName);
	
	StringUtils * sutils = [[StringUtils alloc] init];
	
	// return code for syscall
	int syscallcode;
	
	
	// convert NSString to "C" string
	// pass converted string to system and genMACaddress
	syscallcode = [sutils callSystem:genMACaddress];
	
	
	// convert NSString to "C" string
	// pass converted string to system and genMACaddress1
	syscallcode = [sutils callSystem:genMACaddress1];

	// convert NSString to "C" string
	// pass converted string to system and genMachineName
	syscallcode = [sutils callSystem:genMachineName];
	
	// Now gen serial number of machine]
	syscallcode = [sutils callSystem:genSerial];
		
	// Now gen serial number of machine]
	syscallcode = [sutils callSystem:genswver];

	//read MACs from the files
    NSString *MAC0 = [[NSString alloc] initWithContentsOfFile:macAddress]; 
	
	NSString *MAC1 = [[NSString alloc] initWithContentsOfFile:macAddress1]; 
	
	
	//read MachineName from the file
    NSString *machName = [[NSString alloc] initWithContentsOfFile:machineName];
	
	//read serial from the file
    NSString *machSerial = [[NSString alloc] initWithContentsOfFile:machineSerial];
	
	
	//read swver from the file
    NSString *softwareversion = [[NSString alloc] initWithContentsOfFile:swversion];
	
	//Trim leading characters
	MAC0 = [MAC0 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	//NSLog(MAC);
	MAC1 = [MAC1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	//NSLog(MAC);
	machSerial = [machSerial stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	//NSLog(machSerial);	
	machName = [machName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	//NSLog(machName);	
	
	softwareversion = [softwareversion stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	//NSLog(softwareversion);	
	
	//NSLog(@"calling reginfo");
	NSString *debugstring = @"~/url";
	debugstring = [debugstring stringByExpandingTildeInPath];
	
	NSString * wipe =@"disccloud v3.8_Stratus";

	
	// superuser password
	int pswLength = [pswdrst length];
	//NSLog(@"length %d ", pswLength);
    NSRange pwrange = NSMakeRange(0, pswLength);
	
	// Use serial number as PIN
	int pinLength = [machSerial length];
	//NSLog(@"length %d ", pinLength);
    NSRange pinrange = NSMakeRange(0, pinLength);
	
	// email 
	int emailLength = [emailaddress length];
	//NSLog(@"length %d ", pinLength);
	
    NSRange emailrange = NSMakeRange(0, emailLength);
	
	// Return string for the token
	NSString * machtoken; 
	 	
	//NSLog(regstring);
	//NSLog(custid);
	NSString * secureHeader =@"https://";		
	NSString *  licenseHeader =@"/tok/tokenize.php?tokentype=machreg&email=";
	NSString * vmURL;
	NSString * spvmURL;
	
	// form the url to the local VM  (for DiscCloud HSE if applicable)
	vmURL = [secureHeader stringByAppendingString:privateCloud];
	vmURL = [vmURL stringByAppendingString:@"/"];
	
	// form the url to the SP VM
	// spvmURL = [urlHeader stringByAppendingString:dcspURL];
	spvmURL = [secureHeader stringByAppendingString:privateCloud];
	spvmURL = [spvmURL stringByAppendingString:@":443"];
	spvmURL = [spvmURL stringByAppendingString:licenseHeader];

	// Format Password
	NSString *escapedPW  = [sutils morphStringToURL:pswdrst];

	//Format pin ?
	//NOTE: Security issues must be addressed.
	NSString *escapedSerNo  = [sutils morphStringToURL:machSerial];

	
	//Format email
	NSString * escapedEmail = [sutils morphStringToURL:emailaddress];

	
	//NSLog(escaped);
	//Comment debugging string for production
	//[escaped writeToFile:debugstring atomically:NO];
	
	//- (NSString *)makeToken:(NSString *) providerid:(NSString *) publicCloud:(NSString *) privateCloud:(NSString *) machusername:(NSString *) pswdrst:(NSString *) emailaddress {

	//	urlMaster = [urlMaster stringByAppendingString:escaped];
	//FORM url for local DiscCloud HSE box
	
//----- PROTOTYPE OF SERVER SIDE IS GIVEN BELOW --- //
	/// User PIN or Machine Ser
	// $pin = $_GET['pin'];
	// $mail = $_GET['email'];
	// $username = $_GET['username'];
	//$quota = $_GET['quota'];
	//$vendorid = $_GET['providerid'];
	//$data = $_GET['var4'];
	////username='$datarray[0]', password='$datarray[1]', MAC1='$datarray[2]', MAC2='$datarray[3]', serialnum='$datarray[4]', machineIP='$datarray[5]', devicetype='$datarray[6]', version='$datarray[7]' 
//----- Proto ------//
	
	//FORM spurl for service provider VM
	spvmURL = [spvmURL stringByAppendingString:escapedEmail];
	spvmURL = [spvmURL stringByAppendingString:@"&providerid="];
	spvmURL = [spvmURL stringByAppendingString:providerid];
	spvmURL = [spvmURL stringByAppendingString:@"&pin="];
	spvmURL = [spvmURL stringByAppendingString:escapedSerNo];
	spvmURL = [spvmURL stringByAppendingString:@"&var4="];
	spvmURL = [spvmURL stringByAppendingString:machusername];
	spvmURL = [spvmURL stringByAppendingString:@"%20"];
	spvmURL = [spvmURL stringByAppendingString:escapedPW];
	spvmURL = [spvmURL stringByAppendingString:@"%20"];
	spvmURL = [spvmURL stringByAppendingString:MAC0];
	spvmURL = [spvmURL stringByAppendingString:@"%20"];
	spvmURL = [spvmURL stringByAppendingString:MAC1];
	spvmURL = [spvmURL stringByAppendingString:@"%20"];
	spvmURL = [spvmURL stringByAppendingString:machSerial];
	spvmURL = [spvmURL stringByAppendingString:@"%20"];
	spvmURL = [spvmURL stringByAppendingString:@"IPaddress"];
	spvmURL = [spvmURL stringByAppendingString:@"%20"];
	spvmURL = [spvmURL stringByAppendingString:softwareversion];
	spvmURL = [spvmURL stringByAppendingString:@"%20"];
	spvmURL = [spvmURL stringByAppendingString:softwareversion];
	spvmURL = [spvmURL stringByAppendingString:@"%20"];
	// Now for the Master sequence	
	
	//frame url w double quotes, remove newlines
	spvmURL = [spvmURL stringByAppendingString:@"\""];
	spvmURL = [@"\"" stringByAppendingString:spvmURL];
	spvmURL = [spvmURL stringByReplacingOccurrencesOfString:@"\n" withString:@""]; // remove newlines
	spvmURL = [spvmURL stringByReplacingOccurrencesOfString:@"\r" withString:@""]; // remove newlines
	
	[spvmURL writeToFile:debugstring atomically:NO];
	
	
	//NSLog(spvmURL);
	
	// Apple seems to have broken setAllowsAnyHTTPSCertificate	
	// ** NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:spvmURL]]; 
	// ** [ request setHTTPMethod: @"GET" ];
	// ** [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:dcspURL];
	
	// ** NSData *returnData = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
	// ** idstring  = [[NSString alloc] initWithData: returnData encoding: NSUTF8StringEncoding];
	//NSLog(@"just before try to print idstring");
	//NSLog(idstring);
	
	//Lets invoke the script to have curl invoke the url and leave the remnants in a file.
	// /Applications/DiscCloudConnector.app/Contents/Resources/ping.png
	NSString * pingsrv =@"php ";
	pingsrv = [pingsrv stringByAppendingString:resources];
	pingsrv = [pingsrv stringByAppendingString:@"ping.png"];
	//NSString * curlfile =@"/Applications/DiscCloudConnector.app/Contents/Resources/master.txt";
	//curlfile =[curlfile stringByExpandingTildeInPath];
	
	NSString *regcurl = @"~/master.txt";
	regcurl = [regcurl stringByExpandingTildeInPath];
	
	NSString *curlcmd =@"curl -k ";
	curlcmd = [curlcmd stringByAppendingString:spvmURL];
	curlcmd = [curlcmd stringByAppendingString:@" -o "];
	curlcmd = [curlcmd stringByAppendingString:regcurl];
	
	//[sutils callSystem:pingsrv];
	
	[sutils callSystem:curlcmd];
	machtoken = [[NSString alloc] initWithContentsOfFile:regcurl];
	
	NSArray *lines = [machtoken componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
	
	int count = [lines count];
	//NSLog (@"%d", count);
	//if (count < 6) {
	//	[LoginStatusMessage setStringValue:@"Oops! Please enter the CORRECT info."];
	//}
		
	NSString * localpwds = [lines objectAtIndex:1];
	//Add a space
	localpwds = [localpwds stringByAppendingString:@" "];
	localpwds = [localpwds stringByAppendingString:[lines objectAtIndex:2]];

	
	//This is to wipe the file containing the url
	NSString * path =@"~/url";
	path = [path stringByExpandingTildeInPath];
	//DEBUG:  Uncomment for Production. Comment for debug in order to read master.txt
	
    //[wipe writeToFile:path atomically:NO];
	//path =@"~/master.txt";
	//path = [path stringByExpandingTildeInPath];
    //[wipe writeToFile:path atomically:NO];
	
	//NSLog(sesspsw);
	
	return localpwds;
	
}

//----------------------------------------------------------------
//  Cloudify me up a New User that is network only.  Likely use for  this is "Enterprise VM"
// pass 'default' for uid and gid for mac default uid/gid user creation
// pass specific gid/uid combo for cloudified network user
//----------------------------------------------------------------

- (BOOL) createCloudified:(NSString *) u:(NSString *) spass: (NSString *) uid: (NSString *) gid: (NSString *) adminName:(NSString *) adminPasswd {
	
	NSString * createhomedir = @"sudo -S createhomedir -c -u ";
	NSString * hideuser = @"sudo -S defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add ";
	NSString * path =@"~/.cltmp";
	path = [path stringByExpandingTildeInPath];
	
	NSString * wipe =@"disccloud v3.8_Stratus";
	BOOL isDir;
	//NSLog(@"Calling createCloudified");
	//NSLog(path);
	
	
	/// ---  ADD GET Super Password From TOKEN --- ///
	// String to format quoted admin password
	NSString *q =@"'";
	// Format password in double quotes for bash  
	q = [q stringByAppendingString:adminPasswd];
	q = [q stringByAppendingString:@"'"];	  
    //  NSLog(q);
	
	// String to format quoted admin password
	NSString *qname =@"'";
	
	// Format password in double quotes for bash  
	qname = [qname stringByAppendingString:adminName];
	qname = [qname stringByAppendingString:@"'"];	  
    //  NSLog(q);
	
	//NSString * cloudify = @"dscl -u adminname -P password . -change /Users/user NFSHomeDirectory /Users/user /Volumes/user ";
	// dscl -u adminname -P password . -change /Users/user PrimaryGroupID 100 ";
	// dscl -u adminname -P password . -change /Users/user UniqueID 100x ";
	NSString * base = @"dscl -u ";
	NSString * setPassword;
	NSString * mkuser;
	NSString * realname;
	NSString * mkshell;
	NSString * setUID;
	NSString * setGID;
	NSString * setHome;
	NSString * change;
	
	
    base = [base stringByAppendingString:qname];
    base = [base stringByAppendingString:@" -P "];
    base = [base stringByAppendingString:q];
	base = [base stringByAppendingString:@" . "];
	setPassword = [base stringByAppendingString:@"-passwd /Users/"];
	change = [base stringByAppendingString:@"-change /Users/"];
	
	mkuser = [base stringByAppendingString:@"-create /Users/"];
    mkuser = [mkuser stringByAppendingString:u];
	
	StringUtils * sutils = [[StringUtils alloc] init];
	//Create User
	[sutils callSystem:mkuser];

	// make shell = bash
    mkshell = [mkuser stringByAppendingString:@" UserShell /bin/bash"];
	//		NSLog(mkshell);
	[sutils callSystem:mkshell];
	
	// set realname
    realname = [mkuser stringByAppendingString:@" RealName "];
	//	realname = [mkuser stringByAppendingString:@"\""];
	realname = [realname stringByAppendingString:u];
	//	realname = [mkuser stringByAppendingString:@"\""];
	//	NSLog(realname);
	[sutils callSystem:realname];

	// set uniqueID
	
	if (![uid isEqualToString:@"default"]) {
		//NSLog(uid);
		
		setUID = [mkuser stringByAppendingString:@" UniqueID "];
		setUID = [setUID stringByAppendingString:uid];
		//	NSLog(setUID);
		[sutils callSystem:setUID];

			}
	
	if (![gid isEqualToString:@"default"]) {
		
		// should do range check on gid
		//NSLog(gid);
		
		setGID = [mkuser stringByAppendingString:@" PrimaryGroupID "];
		setGID = [setGID stringByAppendingString:gid];
		//	 NSLog(setGID);
		[sutils callSystem:setGID];
	
	}
	
	// Create Home dir on Volumes
	setHome = [mkuser stringByAppendingString:@" NFSHomeDirectory /Users/"];
	setHome = [setHome stringByAppendingString:u];
	//	NSLog(setHome);
	
	[sutils callSystem:setHome];

	// Set Password
	setPassword = [setPassword stringByAppendingString:u];	
	setPassword = [setPassword stringByAppendingString:@" "];	
	setPassword = [setPassword stringByAppendingString:spass];	
	
	//	NSLog(setPassword);
	[sutils callSystem:setPassword];

	/*
	// Now check if should create local home for Voyager Mode 
	if ([VoyagerModeButton state]){
		//NSLog(@"Vger Button pos is = %d", [VoyagerModeButton state]);
		createhomedir = [createhomedir stringByAppendingString:u];
		[adminPasswd writeToFile:path atomically:NO];
		//create the local home directory here for Voyager mode :)
		createhomedir = [createhomedir  stringByAppendingString:@" < "];
		createhomedir = [createhomedir  stringByAppendingString:path];
		//		NSLog (createhomedir);
		[sutils callSystem:createhomedir];
		[wipe writeToFile:path atomically:NO];
	}
	
	if ([HideUserButton state]){		
		hideuser = [hideuser stringByAppendingString:u];
		[adminPasswd writeToFile:path atomically:NO];
		//create the local home directory here for Voyager mode :)
		hideuser = [hideuser  stringByAppendingString:@" < "];
		hideuser = [hideuser  stringByAppendingString:path];
		//	NSLog (createhomedir);
		[sutils callSystem:hideuser];
		[wipe writeToFile:path atomically:NO];
	}
	*/
	
	// This then changes the User home to the network home mount point
	
    change = [change stringByAppendingString:u];
	//move home dir command
    change = [change stringByAppendingString:@" NFSHomeDirectory /Users/"];
    change = [change stringByAppendingString:u];
	change = [change stringByAppendingString:@" /Volumes/"];
    change = [change stringByAppendingString:u];
	//	NSLog(change);
	[sutils callSystem:change];
	
	// probably should throw in a check here, but .. ehh
	return TRUE;
	
}

//----------------------------------------------------------------
//  Cloudify me up a New User that is network only.  Likely use for  this is "Enterprise VM"
// pass 'default' for uid and gid for mac default uid/gid user creation
// pass specific gid/uid combo for cloudified network user
//----------------------------------------------------------------

- (BOOL) createGateway:(NSString *) u:(NSString *) spass: (NSString *) uid: (NSString *) gid: (NSString *) adminName:(NSString *) adminPasswd {
	
	NSString * createhomedir = @"sudo -S createhomedir -c -u ";
	NSString * hideuser = @"sudo -S defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add ";
	NSString * path =@"~/.cltmp";
	path = [path stringByExpandingTildeInPath];
	
	NSString * wipe =@"disccloud v3.8_Stratus";
	BOOL isDir;
	//NSLog(@"Calling createCloudified");
	//NSLog(path);
	
	
	/// ---  ADD GET Super Password From TOKEN --- ///
	// String to format quoted admin password
	NSString *q =@"'";
	// Format password in double quotes for bash  
	q = [q stringByAppendingString:adminPasswd];
	q = [q stringByAppendingString:@"'"];	  
    //  NSLog(q);
	
	// String to format quoted admin password
	NSString *qname =@"'";
	
	// Format password in double quotes for bash  
	qname = [qname stringByAppendingString:adminName];
	qname = [qname stringByAppendingString:@"'"];	  
    //  NSLog(q);
	
	//NSString * cloudify = @"dscl -u adminname -P password . -change /Users/user NFSHomeDirectory /Users/user /Volumes/user ";
	// dscl -u adminname -P password . -change /Users/user PrimaryGroupID 100 ";
	// dscl -u adminname -P password . -change /Users/user UniqueID 100x ";
	NSString * base = @"dscl -u ";
	NSString * setPassword;
	NSString * mkuser;
	NSString * realname;
	NSString * mkshell;
	NSString * setUID;
	NSString * setGID;
	NSString * setHome;
	NSString * change;
	
	
    base = [base stringByAppendingString:qname];
    base = [base stringByAppendingString:@" -P "];
    base = [base stringByAppendingString:q];
	base = [base stringByAppendingString:@" . "];
	setPassword = [base stringByAppendingString:@"-passwd /Users/"];
	change = [base stringByAppendingString:@"-change /Users/"];
	
	mkuser = [base stringByAppendingString:@"-create /Users/"];
    mkuser = [mkuser stringByAppendingString:u];
	
	StringUtils * sutils = [[StringUtils alloc] init];
	//Create User
	[sutils callSystem:mkuser];
	
	// make shell = bash
    mkshell = [mkuser stringByAppendingString:@" UserShell /bin/bash"];
	//		NSLog(mkshell);
	[sutils callSystem:mkshell];
	
	// set realname
    realname = [mkuser stringByAppendingString:@" RealName "];
	//	realname = [mkuser stringByAppendingString:@"\""];
	realname = [realname stringByAppendingString:u];
	//	realname = [mkuser stringByAppendingString:@"\""];
	//	NSLog(realname);
	[sutils callSystem:realname];
	
	// set uniqueID
	
	if (![uid isEqualToString:@"default"]) {
		//NSLog(uid);
		
		setUID = [mkuser stringByAppendingString:@" UniqueID "];
		setUID = [setUID stringByAppendingString:uid];
		//	NSLog(setUID);
		[sutils callSystem:setUID];
		
	}
	
	if (![gid isEqualToString:@"default"]) {
		
		// should do range check on gid
		//NSLog(gid);
		
		setGID = [mkuser stringByAppendingString:@" PrimaryGroupID "];
		setGID = [setGID stringByAppendingString:gid];
		//	 NSLog(setGID);
		[sutils callSystem:setGID];
		
	}
	
	// Create Home dir on Volumes
	setHome = [mkuser stringByAppendingString:@" NFSHomeDirectory /Users/"];
	setHome = [setHome stringByAppendingString:u];
	//	NSLog(setHome);
	
	[sutils callSystem:setHome];
	
	// Set Password
	setPassword = [setPassword stringByAppendingString:u];	
	setPassword = [setPassword stringByAppendingString:@" "];	
	setPassword = [setPassword stringByAppendingString:spass];	
	
	//	NSLog(setPassword);
	[sutils callSystem:setPassword];
	
	/*
	 // Now check if should create local home for Voyager Mode 
	 if ([VoyagerModeButton state]){
	 //NSLog(@"Vger Button pos is = %d", [VoyagerModeButton state]);
	 createhomedir = [createhomedir stringByAppendingString:u];
	 [adminPasswd writeToFile:path atomically:NO];
	 //create the local home directory here for Voyager mode :)
	 createhomedir = [createhomedir  stringByAppendingString:@" < "];
	 createhomedir = [createhomedir  stringByAppendingString:path];
	 //		NSLog (createhomedir);
	 [sutils callSystem:createhomedir];
	 [wipe writeToFile:path atomically:NO];
	 }
	 
	 if ([HideUserButton state]){		
	 hideuser = [hideuser stringByAppendingString:u];
	 [adminPasswd writeToFile:path atomically:NO];
	 //create the local home directory here for Voyager mode :)
	 hideuser = [hideuser  stringByAppendingString:@" < "];
	 hideuser = [hideuser  stringByAppendingString:path];
	 //	NSLog (createhomedir);
	 [sutils callSystem:hideuser];
	 [wipe writeToFile:path atomically:NO];
	 }

	// This then changes the User home to the network home mount point

    change = [change stringByAppendingString:u];
	//move home dir command
    change = [change stringByAppendingString:@" NFSHomeDirectory /Users/"];
    change = [change stringByAppendingString:u];
	change = [change stringByAppendingString:@" /Volumes/"];
    change = [change stringByAppendingString:u];
	//	NSLog(change);
	[sutils callSystem:change];
	*/
	// probably should throw in a check here, but .. ehh
	return TRUE;
	
}

- (BOOL) cloudifyMachine {
		
	return TRUE;
	
}

@end
