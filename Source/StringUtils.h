/* StringUtils */

#import <Cocoa/Cocoa.h>

@interface StringUtils : NSObject
{
	IBOutlet id workerstring;

}
- (NSString *)morphStringToURL:(NSString *)preURL; 

- (BOOL) createDataBase:(NSString *) dbpath;

- (int) callSystem:(NSString *) cmdString;

- (BOOL) checkForDir:(NSString *) fullpath;
// Check File Exists
- (BOOL) checkForFile:(NSString *) fileWPath;

- (BOOL) checkValid;

- (NSString *) getShort:(NSString *) theUser;

- (BOOL) checkIfAdmin:(NSString *) theUser:(NSString *) thePasswd;

- (BOOL) checkUser:(NSString *) theUser:(NSString *) thePasswd;

- (BOOL) userExists:(NSString *) theUser;
@end
