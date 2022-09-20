#import "StringUtils.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "User.h"

@implementation StringUtils

NSString *path2 = @"/Users/mjm/.urldebug";
NSString *tmpath;
NSString *mkfolder = @"mkdir ";


/******************************************************************************************************/
/* // Method for checking if File Exists                                                              */
/******************************************************************************************************/

- (BOOL) checkForFile:(NSString *) fileWPath {
	
	NSFileManager *fm = [NSFileManager defaultManager]; 	
	
	NSString * fileWithPath = fileWPath;
	
	//NSLog(fileWPath);
	
	if ([fm fileExistsAtPath:fileWPath]) {
		
		return TRUE;
	} else { return FALSE; }
	
}

/******************************************************************************************************/
/* // Check for Directory                                                              */
/******************************************************************************************************/

- (BOOL) checkForDir:(NSString *) fullpath {
	
	NSFileManager *fm = [NSFileManager defaultManager]; 	
	BOOL isDir;
	
	//NSString * fileWithPath = fileWPath;
	
	if ([ fm fileExistsAtPath:fullpath isDirectory:&isDir] && isDir) {
		
		return TRUE;
	} else { return FALSE; }
	
}

//return an escaped string suitable for use as URL
- (NSString *)morphStringToURL:(NSString *)preURL { 

//NSLog(preURL);

int preURLength = [preURL length];
//NSLog(@"length %d ", preURLength);
NSRange urlrange = NSMakeRange(0, preURLength);

//Format license token 
NSMutableString *escaped = [NSMutableString stringWithString:(NSString *)preURL]; 
[escaped replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@"@" withString:@"%40" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@"\t" withString:@"%09" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@"#" withString:@"%23" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@"<" withString:@"%3C" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@">" withString:@"%3E" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@"\"" withString:@"%22" options:NSCaseInsensitiveSearch range:urlrange];
[escaped replaceOccurrencesOfString:@"\n" withString:@"%0A" options:NSCaseInsensitiveSearch range:urlrange];

// Debug String
//[escaped writeToFile:path2 atomically:NO];
	

	/*
	//spvmURL needs to be arg
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:spvmURL]]; 
	[ request setHTTPMethod: @"GET" ];
	[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:dcspURL];
	NSData *returnData = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
	//  garbage  = [[NSString alloc] initWithData: returnData encoding: NSUTF8StringEncoding];
	NSString *userParams  = [[NSString alloc] initWithData: returnData encoding: NSUTF8StringEncoding];
	*/
	
	//NSString *userParams =@"somecode:bobbybilly:129.233.1.23:8086";
	//separate return string fields  

	return escaped;
	
}

/**********************************************************************************************/
// // Make a system call with specified string.
/**********************************************************************************************/
- (int) callSystem:(NSString *) cmdString {
	//should be converted to a void method
	// convert NSString to "C" string
	int eCode;
	unsigned int lengthOfShCmd = [cmdString length];
	char cmd[lengthOfShCmd + 1];
	strcpy(cmd, [cmdString cString]);
	eCode = system(cmd);
	
	//NSLog (@"%d", errorCode);
	if (eCode = 1) { // something went wrong.
		return eCode;
	}
	return eCode;
}	

/******************************************************************************************************/
/* Create a DiscCloud sqlite database instance of 'db'  externally named dbName inclusive of full path*/
/******************************************************************************************************/
- (BOOL) createDataBase:(NSString *) dbpath
{
	
	//   NSString * dbName = [DBName stringValue];
    NSFileManager *fm = [NSFileManager defaultManager]; 	
	// NSString * dbName = @"~/Library/Application Support/DiscCloud";
	//            dbName = [dbName stringByExpandingTildeInPath];
	//			 success = [fm createDirectoryAtPath:dbName attributes:nil];
	//			 dbName = [dbName stringByAppendingString:@"/dcdb.db"];
	// NSLog(dbpath);
	
	// Strings
	NSString * path =@"~/.cltmp";
	path = [path stringByExpandingTildeInPath];
	NSString * wipe =@"disccloud v3.8_Stratus";
	
	// create strings for fingerprint calls
	NSString * macAddress =@"~/.MAC_address";
	macAddress = [macAddress stringByExpandingTildeInPath];
	
	NSString * macAddress1 =@"~/.MAC1_address";
	macAddress1 = [macAddress1 stringByExpandingTildeInPath];
	
	NSString * machineName =@"~/.machine_name";
	machineName = [machineName stringByExpandingTildeInPath];
	
	NSString * genMACaddress = @"ifconfig en0 | grep ether | sed -e 's/ether //g' | sed s/://g  > ";
    genMACaddress = [genMACaddress stringByAppendingString:macAddress];
	
	NSString * genMACaddress1 = @"ifconfig en1 | grep ether | sed -e 's/ether //g' | sed s/://g  > ";
    genMACaddress1 = [genMACaddress1 stringByAppendingString:macAddress1];
	
	NSString * genMachineName = @"uname -n | egrep -o '^[^.]+' > ";
	genMachineName = [genMachineName stringByAppendingString:machineName];
	
	
	
	//NSLog(genMACaddress);
	//NSLog(genMachineName);
	
	// convert NSString to "C" string
	// pass converted string to system and genMACaddress
	[self callSystem:genMACaddress];
	
	// convert NSString to "C" string
	// pass converted string to system and genMACaddress
	[self callSystem:genMACaddress1];
	
	// convert NSString to "C" string
	// pass converted string to system and genMachineName
	[self callSystem:genMachineName];
	
	// Now read in the MAC address and the Machine Name
	
	//read MAC from the file
    NSString *MAC = [[NSString alloc] initWithContentsOfFile:macAddress];
    if(MAC == nil)
    {
		//NSLog(@"Error reading MAC file");
        return 1;
    }
	// write to data base
	
	//read MachineName from the file
    NSString *machName = [[NSString alloc] initWithContentsOfFile:machineName];
    if(machName == nil)
    {
        //NSLog(@"Error reading Name file");
        return 1;
    }
	
	NSData *d = [NSData dataWithContentsOfFile:@"/Applications/DiscCloudConnect.app/Contents/Resources/disccloud.icns"];
	
	//NSLog(dbpath);
	
	FMDatabase* db = [FMDatabase databaseWithPath:dbpath];  
	if (![db open]) {
        NSLog(@"Error 0010.");
    }
	
	[db setShouldCacheStatements:YES];
	
	// Create DiscCloud Data Model
	// Create PI Personal Information
	[db executeUpdate:@"create table PI (guid text, firstname text, lastname text, email text, phone text, mobile text, street text, city text, stateprov text, postal text, url text, ID text, pubKey text, picture blob, i INTEGER PRIMARY KEY)"];
	
	// Create PI Personal Information
	[db executeUpdate:@"create table User (username text, homedir text, uid text, gid text, groupname text, guid text, expiry text, cpuuse text, memuse text, quota text, key blob, keystate blob, vdriveid text, pswdreset text, isCloudified text, isTokenized text,  isAirplane text, isSyncronized text, syncLog blob, DiscCloudLicense text, i INTEGER PRIMARY KEY)"];
	[db executeUpdate:@"create table vDrive (drivename text, vdriveid text, isdedicated text, ismovable text, ismounted text, mountpoint text, size text, timestamp text, utilization text, volumename text, guid text, signature text, archiveserver text, i INTEGER PRIMARY KEY)"];
	[db executeUpdate:@"create table DiscCloud (bonjour text, dhcp int, hostname text, ipaddress text, subnetmask text, isproxy int, port text, maxconnects text, version text, vmpath text, disccloudid text, i INTEGER PRIMARY KEY)"];
	[db executeUpdate:@"create table sysConfig (token text, discCloudPublic text, discCloudPrivate text, providerID text, deviceToken text, tmpUser text, tmpPassword text, email text, i INTEGER PRIMARY KEY)"];
	[db executeUpdate:@"create table xReq (xType text, xState text, xRequestor text, xCommand text, xParams text, xOptions text, xHost text,  i INTEGER PRIMARY KEY)"];
	[db beginTransaction];
	
	// Create entry for user disccloud
	[db executeUpdate:@"insert into PI (guid, firstname, lastname, email, phone, mobile, street, city, stateprov, postal, url, ID, pubKey, picture) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" ,
	 nil, @"Disc", @"Cloud", nil, nil, nil, nil, nil, nil, nil, @"http://www.disccloud.com", @"ID", @"pubkey", d];
	
	[db executeUpdate:@"insert into User (username, homedir, uid, gid, groupname, guid, expiry, cpuuse, memuse, quota, vdriveid, pswdreset, isCloudified, isTokenized, isAirplane, isSyncronized, syncLog, DiscCloudLicense ) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )", 
	 @"disccloud", @"/home/disccloud", @"1001", @"1001", @"disccloud-adm", nil, nil, nil, nil, nil, nil, nil, @"YES", @"NO", @"NO", @"NO", nil, nil ];
	
	[db executeUpdate:@"insert into vDrive (drivename, size, mountpoint) values (?, ?, ?)" , @"dc3.8-0.img", @"256GB", @"/export/home"];
	[db executeUpdate:@"insert into vDrive (drivename, size, mountpoint) values (?, ?, ?)" , @"dc3.8-1.img", @"256GB", @"/export/share"];
	[db executeUpdate:@"insert into DiscCloud (version) values (?)" , @"3.8"];
	[db executeUpdate:@"insert into sysConfig (token, discCloudPublic, discCloudPrivate, providerID, deviceToken, tmpUser, tmpPassword, email) values (?, ?, ?, ?, ?, ?, ?, ?)" , @"NONE", @"NONE", @"NONE", @"NONE", @"NONE", @"NONE", @"NONE", @"NONE"];
	
	[db executeUpdate:@"insert into xReq (xType, xState, xRequestor, xCommand, xParams, xOptions  ) values (?, ?, ?, ?, ?, ? )",  @"reserved", @"passive", @"none", @"null", @"null", @"null"];		
	[db commit];
	
	//	update t3 set a = ? where a = ?" , [NSNumber numberWithInt:newVal], [NSNumber numberWithInt:foo]];
	//	[db executeUpdate:@"update User set quota = ? where username = ?", @"10GB", @"disccloud"];
	//  [db commit];
	
	[db close];
}	


/*********************************************************************************************/
// Check User Exists return true if ok		
/*********************************************************************************************/		
- (BOOL) userExists:(NSString *) theUser  {
	
	
	User* user = [User userWithUsername: theUser];
	
	if (user) {
		// there is such a user
		return TRUE;
	} else {
		
		// there is not
		return FALSE;
	}
	
}

/*********************************************************************************************/
// Check User with Password		
/*********************************************************************************************/
- (BOOL) checkUser:(NSString *) theUser:(NSString *) thePasswd  {
	
	
	User* user = [User userWithUsername: theUser password: thePasswd];
	
	if (user) {
		// there is such a user
		return TRUE;
	} else {
		
		// there is not
		return FALSE;
	}
	
}


/*********************************************************************************************/
/* Check Admin Credentials, return true if admin	 */	
/*********************************************************************************************/

- (BOOL) checkIfAdmin:(NSString *) theUser:(NSString *) thePasswd  {
	
	
	User* user = [User userWithUsername: theUser password: thePasswd];
	
	if (user) {		
		if ([user admin]) {return TRUE;}
	} else {
		return FALSE;
	}
	
}

/*********************************************************************************************/
/* Return shortname for user 	 */	
/*********************************************************************************************/

- (NSString *) getShort:(NSString *) theUser  {
	
	NSString * dummy = @"dummy_username";
	User* user = [User userWithUsername: theUser];
	
	if (user) { 
	return ([user name]); } 
	else { 
		return dummy; 
	}
}

/******************************************************************************************************/
/* Check if Licensed                                                                                  */
/******************************************************************************************************/
- (BOOL) checkValid
{
	
	NSString * itstrue=@"OK";
	NSString * homepath =@"~/";
	
	NSString * dbPath =@"/Library/Application Support/DiscCloud/.dcdb"; 
	homepath = [homepath stringByExpandingTildeInPath];
	dbPath = [homepath stringByAppendingString:dbPath];
	
	
	NSFileManager *fm = [NSFileManager defaultManager]; 		
	FMDatabase* db = [FMDatabase databaseWithPath:dbPath];  
	
	if (![db open]) {
	    [self openAlertPanel:@"Authorization Access Warning! Try registering license information."]; 
		return FALSE;
	} else { NSLog (@"ok."); }
	
	//  FMResultSet *rs = [db executeQuery:@"select rowid,* from sysConfig"];
	FMResultSet *rs = [db executeQuery:@"select rowid,* from sysConfig"];
	
	[rs next];
	
	//   NSString * installed = [rs stringForColumn:@"guid"];
	
	
	NSString * isValid = [rs stringForColumn:@"signature"];
	//NSLog(isValid);
	
	
	if ([isValid isEqualToString:@"Accepted"]){
		//NSLog(@"thinks its good");
	return YES; } else {		//NSLog(@"thinks its bad");
	return NO; }
}


/*
- (void)wrToSRTVConfig:(NSString *)filedat
{
NSFileManager *fmm = [NSFileManager defaultManager];
BOOL isDir;
sonarfolder = [sonarfolder stringByExpandingTildeInPath];
if (![fmm fileExistsAtPath:sonarfolder isDirectory:&isDir]) {
[fmm createDirectoryAtPath:sonarfolder attributes:nil];
sonarfolder = [sonarfolder stringByAppendingString:@"/presets"];
[fmm createDirectoryAtPath:sonarfolder attributes:nil];
}

//NSLog(sonarfolder);
tmpath = [path stringByExpandingTildeInPath];
[filedat writeToFile:tmpath atomically:YES];
return;
}

- (void)rmProfile
{
NSFileManager *fmm = [NSFileManager defaultManager];
BOOL isDeleted;
path = [path stringByExpandingTildeInPath];
if ([fmm fileExistsAtPath:path]) {
isDeleted = [fmm removeFileAtPath:path handler:nil];
//NSLog(path);
}
return;
}

- (void)wrStamp:(NSString *)stampdat
{

path2 = [path2 stringByExpandingTildeInPath];
[stampdat writeToFile:path2 atomically:YES];
}
*/		   
@end
