//
//  User.m
//  NetworkAuthentication
//

#import "User.h"
#import "DirServiceWrapper.h"
#include <grp.h>
#include <pwd.h>
#include <unistd.h>
#include <sys/stat.h>

@implementation User

- (id) initWithUsername: (NSString*)username fromDirectoryService: (DirServiceWrapper*) dirService {
	if (self = [super init]) {						
		// get infos from DirectoryService
		if (dirService == nil) dirService = [[[DirServiceWrapper alloc] init] autorelease];		
		
		NSDictionary* userInfo = [dirService attributeDataForNodeOfType: kDSStdRecordTypeUsers
																  value: [username cStringUsingEncoding:NSUTF8StringEncoding]
																  attr1: kDSNAttrRecordName
																  attr2: kDS1AttrUniqueID
																  attr3: kDS1AttrPrimaryGroupID
																  attr4: kDS1AttrDistinguishedName
																  attr5: kDS1AttrGeneratedUID
								                                  attr6: kDS1AttrNFSHomeDirectory
																  attr7: kDSNAttrIPAddress
																  attr8: kDS1AttrENetAddress
								                                  attr9: kDSNAttrDNSName
																  attr10: kDSNAttrHomeDirectory
																  attr11: NULL];
		NSDictionary* adminInfo= [dirService attributeDataForNodeOfType: kDSStdRecordTypeGroups
																  value: "admin"
																  attr1: kDSNAttrRecordName
																  attr2: kDSNAttrGroupMembership
																  attr3: NULL
																  attr4: NULL
																  attr5: NULL
																  attr6: NULL
																  attr7: NULL
																  attr8: NULL
																  attr9: NULL
																  attr10: NULL
																  attr11: NULL];
		name     = [[[userInfo objectForKey:[NSString stringWithCString:kDSNAttrRecordName encoding:NSUTF8StringEncoding]] objectAtIndex:0] retain];		
		realName = [[[userInfo objectForKey:[NSString stringWithCString:kDS1AttrDistinguishedName encoding:NSUTF8StringEncoding]] objectAtIndex:0] retain];
		home     = [[[userInfo objectForKey:[NSString stringWithCString:kDS1AttrNFSHomeDirectory encoding:NSUTF8StringEncoding]] objectAtIndex:0] retain];		
		IP_Address  = [[[userInfo objectForKey:[NSString stringWithCString:kDSNAttrIPAddress encoding:NSUTF8StringEncoding]] objectAtIndex:0] retain];		
		en_address  = [[[userInfo objectForKey:[NSString stringWithCString:kDS1AttrENetAddress encoding:NSUTF8StringEncoding]] objectAtIndex:0] retain];		
		dnsname     = [[[userInfo objectForKey:[NSString stringWithCString:kDSNAttrDNSName encoding:NSUTF8StringEncoding]] objectAtIndex:0] retain];		
		guid     = [[[userInfo objectForKey:[NSString stringWithCString:kDS1AttrGeneratedUID encoding:NSUTF8StringEncoding]] objectAtIndex:0] retain];
		uid      = [[[userInfo objectForKey:[NSString stringWithCString:kDS1AttrUniqueID encoding:NSUTF8StringEncoding]] objectAtIndex:0] intValue];	
		gid      = [[[userInfo objectForKey:[NSString stringWithCString:kDS1AttrPrimaryGroupID encoding:NSUTF8StringEncoding]] objectAtIndex:0] intValue];			
		
		NSArray* adminMembers = [adminInfo objectForKey:[NSString stringWithCString:kDSNAttrGroupMembership encoding:NSUTF8StringEncoding]];		
		admin = [adminMembers containsObject:realName] || [adminMembers containsObject:name];
		
		if (name != nil) {	
			groups = NULL;
			
			int groupsTemp[256];
			int groupsize = 256;
			getgrouplist([name cStringUsingEncoding:NSUTF8StringEncoding] , gid, groupsTemp, &groupsize);
			if (groupsize>1) {
				groups = malloc( sizeof(int) * groupsize );
				groups[groupsize-1]=-1;
				int i=0;
				for(i=1; i<groupsize; i++) {
					groups[i-1] = groupsTemp[i];
				}
			}
		} else {
			[self release];
			return nil;					
		}
	}
	return self;
}

- (void) dealloc {
	[name release];
	[realName release];
	[guid release];
	if (groups != NULL) free(groups);
	[super dealloc];
}

- (NSString*) name {
	return name;
}
- (NSString*) realName {
	return realName;
}

- (NSString*) getHome {
	return home;
}

- (NSString*) getIP {
	return IP_Address;
}

- (NSString*) getMac {
	return en_address;
}

- (NSString*) getDNS {
	return dnsname;
}

- (NSString*) getGUID {
	return guid;
}
- (int) gid {
	return gid;
}
- (int) uid {
	return uid;
}
- (BOOL) admin {
	return admin;
}
- (int*) groups
{
	return groups;
}
- (NSString*) description {
	return [NSString stringWithFormat:@"%@=%@ (%d, %d), Admin=%d", name, realName, uid, gid, admin];
}

-  (BOOL) accessAllowedToFileIntern: (NSString*) fileName {
	if (uid == 0) return YES;
	struct stat fileInfo;
	@try {
		const char* fName = [fileName fileSystemRepresentation];
		if (stat(fName, &fileInfo)==0) {
			// check owner
			if (fileInfo.st_uid==uid) return YES;
			
			// check other				
			if ((fileInfo.st_mode&S_IROTH)==S_IROTH || (fileInfo.st_mode&S_IXOTH)==S_IXOTH) {
				return YES;
			}		

			// check group
			if (groups != NULL && ((fileInfo.st_mode&S_IRGRP)==S_IRGRP || (fileInfo.st_mode&S_IXGRP)==S_IXGRP) ) {
				int i=0;
				while(groups[i]>=0) {
					if (fileInfo.st_gid==groups[i]) return YES;
					++i;
				} 
			}
		}
	}
	@catch (NSException *exception) {
		//NSLog(@"User.accessAllowedToFileIntern: Caught for path %@ - %@: %@", fileName, [exception name], [exception  reason]);
	}
	@finally {
	}
	
	return NO;
}

- (BOOL) accessAllowedToFile: (NSString*) fileName {
	BOOL rc=NO;
	while( [fileName length]>1 && (rc=[self accessAllowedToFileIntern:fileName]) ) {
		fileName = [fileName stringByDeletingLastPathComponent];
	}
	
	return rc;
}


+ (User*) userWithUsername: (NSString*) username password: (NSString*) passWord {

	DirServiceWrapper* dirService = [[[DirServiceWrapper alloc] init] autorelease];
	
	if ([dirService authenticateUser:[username cStringUsingEncoding:NSUTF8StringEncoding]
							password:[passWord cStringUsingEncoding:NSUTF8StringEncoding]])
	{
		return [[[User alloc] initWithUsername:username fromDirectoryService:dirService] autorelease];
	}
	return nil;
}

+ (User*) userWithUsername: (NSString*) username {
	return [[[User alloc] initWithUsername:username fromDirectoryService:nil] autorelease];
}

@end
