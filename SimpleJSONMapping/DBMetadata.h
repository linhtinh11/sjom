//
//  DBMetadata.h
//  msc
//
//  Created by trung on 9/28/15.
//  Copyright © 2015 ht. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBProfile;

@interface DBMetadata : NSObject

@property (copy, nonatomic) NSString *size;
@property (copy, nonatomic) NSString *hashContent;
@property (copy, nonatomic) NSNumber *bytes;
@property (copy, nonatomic) NSNumber *thumbExists;
@property (copy, nonatomic) NSString *rev;
@property (copy, nonatomic) NSDate *modified;
@property (copy, nonatomic) NSString *path;
@property (copy, nonatomic) NSNumber *isDir;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *root;
@property (strong, nonatomic) NSArray *contents;
@property (copy, nonatomic) NSNumber *sharedFolder;
@property (copy, nonatomic) NSNumber *readOnly;
@property (copy, nonatomic) NSString *parentSharedFolderId;

@end
