//
//  DirServiceWrapper.h
//  NetworkAuthentication
//
//

#import <Cocoa/Cocoa.h>
#import <DirectoryService/DirectoryService.h>


@interface DirServiceWrapper : NSObject {
	tDirReference     dsRef;
	tDirNodeReference dsSearchNodeRef;
}

- (NSDictionary*) attributeDataForNodeOfType: (const char*) type value: (const char*) value attr1: (const char*) attr1 attr2: (const char*) attr2 attr3: (const char*) attr3 attr4: (const char*) attr4 attr5: (const char*) attr5 attr6: (const char*) attr6 attr7: (const char*) attr7 attr8: (const char*) attr8 attr9: (const char*) attr9 attr10: (const char*) attr10 attr11: (const char*) attr11 ;

- (BOOL) authenticateUser: (const char*) username password: (const char*) password;

@end
