//
//  User.h
//  NetworkAuthentication
//
//

#import <Cocoa/Cocoa.h>

@interface User : NSObject {
	NSString* name;
	NSString* realName;
	NSString* guid;
    NSString* home;
	NSString* IP_Address;
	NSString* en_address;
	NSString* dnsname;
	int gid;
	int uid;
	BOOL admin;
	int* groups;
}

- (NSString*) name;
- (NSString*) realName;
- (NSString*) getGUID;
- (NSString*) getHome;
- (NSString*) getIP;
- (NSString*) getMac;
- (NSString*) getDNS;

- (int) gid;
- (int) uid;
- (BOOL) admin;
- (int*) groups;

- (BOOL) accessAllowedToFile: (NSString*) fileName;

+ (User*) userWithUsername: (NSString*) username password: (NSString*) passWord; 
+ (User*) userWithUsername: (NSString*) username; 

@end
