//
//  SimpleJSONObjectMapping.h
//  msc
//
//  Created by trung on 9/15/15.
//  Copyright (c) 2015 ht. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SIMPLE_JSON_FORMAT_NONE,
    SIMPLE_JSON_FORMAT_STANDARD
} SIMPLE_JSON_FORMAT;

@interface SimpleJSONObjectMapping : NSObject

- (id) initWithAdditionalMapping:(NSDictionary*)map;
- (void) setAdditonalMapping:(NSDictionary*)map;
- (void) setDateFormater:(NSDateFormatter*)formater;
- (void) addRelationMapping:(NSString*)key map:(SimpleJSONObjectMapping*)map class:(Class)_class;
- (void) setExcludeAttributes:(NSArray*)list;

- (id) objectWithDic:(NSDictionary *)dic class:(Class)_class format:(SIMPLE_JSON_FORMAT)format error:(NSError **)error;
- (id) JSONWithObject:(id)object format:(SIMPLE_JSON_FORMAT)format error:(NSError **)error;

@end
