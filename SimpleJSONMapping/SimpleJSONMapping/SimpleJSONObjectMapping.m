//
//  SimpleJSONObjectMapping.m
//  msc
//
//  Created by trung on 9/15/15.
//  Copyright (c) 2015 ht. All rights reserved.
//

#import "SimpleJSONObjectMapping.h"
#import <objc/runtime.h>

@interface AttributeMetadata : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *type;

- (id)initWithName:(NSString*)name type:(NSString*)type;

@end

@implementation AttributeMetadata

- (id)initWithName:(NSString *)name type:(NSString *)type
{
    self = [super init];
    if (self) {
        self.name = name;
        self.type = type;
    }
    return self;
}

@end

@interface RelationMetadata : NSObject

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) SimpleJSONObjectMapping *map;
@property (strong, nonatomic) Class _class;

- (id)initWithKey:(NSString*)key map:(SimpleJSONObjectMapping*)map class:(Class)_class;

@end

@implementation RelationMetadata

- (id)initWithKey:(NSString *)key map:(SimpleJSONObjectMapping *)map class:(__unsafe_unretained Class)_class
{
    self = [super init];
    if (self) {
        self.key = key;
        self.map = map;
        self._class = _class;
    }
    return self;
}

@end

@interface SimpleJSONObjectMapping ()

@property (strong, nonatomic) NSDictionary *mapping;
@property (strong, nonatomic) NSMutableArray *attributes;
@property (strong, nonatomic) NSMutableArray *relations;
@property (strong, nonatomic) NSDateFormatter *formater;
@property (strong, nonatomic) NSArray *excludes;

@end

@implementation SimpleJSONObjectMapping

- (id) init
{
    self = [super init];
    if (self) {
        [self selfInit];
    }
    return self;
}

- (id) initWithAdditionalMapping:(NSDictionary *)map
{
    self = [super init];
    if (self) {
        [self selfInit];
        self.mapping = map;
    }
    return self;
}

- (void) selfInit
{
    self.mapping = nil;
    self.attributes = [[NSMutableArray alloc] init];
    self.relations = [[NSMutableArray alloc] init];
    self.formater = nil;
}

- (void) setAdditonalMapping:(NSDictionary *)map
{
    if (map) {
        self.mapping = map;
    }
}

- (void) setDateFormater:(NSDateFormatter *)formater
{
    self.formater = formater;
}

- (void) setExcludeAttributes:(NSArray*)list
{
    self.excludes = [[NSArray alloc] initWithArray:list];
}

- (BOOL) isExcluded:(NSString*)attr
{
    BOOL result = NO;
    
    if (self.excludes) {
        for (NSString *str in self.excludes) {
            if ([str isEqualToString:attr]) {
                result = YES;
                break;
            }
        }
    }
    
    return result;
}

- (BOOL) isSafeForMapping:(NSString*)type
{
    BOOL result = NO;
    static dispatch_once_t onceToken;
    static NSDictionary *safeList;
    dispatch_once(&onceToken, ^{
        safeList = @{@"_": [NSNumber numberWithBool:YES],
                     @"NSString": [NSNumber numberWithBool:YES],
                     @"NSNumber": [NSNumber numberWithBool:YES]
                     };
    });
    if ([safeList objectForKey:type]) {
        result = YES;
    }
    
    return result;
}

- (void) addRelationMapping:(NSString *)key map:(SimpleJSONObjectMapping *)map class:(Class)_class
{
    if (key && map) {
        [self.relations addObject:[[RelationMetadata alloc] initWithKey:key map:map class:_class]];
    }
}

- (nullable id) getMappingValueForKey:(NSString*)key from:(NSDictionary*)dic
{
    NSArray *arr = [key componentsSeparatedByString:@"/"];
    NSDictionary *tmpDic = dic;
    id result = nil;
    for (int i=0; i<arr.count; i++) {
        if (i < arr.count -1 ) {
            // loop into nested dic
            tmpDic = [tmpDic objectForKey:[arr objectAtIndex:i]];
            if (![tmpDic isKindOfClass:[NSDictionary class]]) {
                break;
            }
        } else {
            // try to map
            result = [tmpDic objectForKey:[arr objectAtIndex:i]];
        }
    }
    
    return result;
}

- (NSMutableArray*) getMappingValueForArray:(NSString*)key value:(NSString*)value from:(NSDictionary*)dic format:(SIMPLE_JSON_FORMAT)format
{
    NSMutableArray *result = nil;
    id tmp = [dic objectForKey:value];
    RelationMetadata *relation = [self getRelationMapForKey:key];
    
    if (relation) {
        SimpleJSONObjectMapping *map = relation.map;
        if (map && tmp && [tmp isKindOfClass:[NSArray class]]) {
            result = [[NSMutableArray alloc] initWithCapacity:[tmp count]];
            for (NSDictionary *dic2 in tmp) {
                NSError *error = nil;
                id tmp2 = [map objectWithDic:dic2 class:relation._class format:format error:&error];
                if (!error && tmp2) {
                    [result addObject:tmp2];
                }
            }
        }
    }
    
    return result;
}

- (id) getMappingValueForObject:(NSString*)key value:(NSString*)value from:(NSDictionary*)dic format:(SIMPLE_JSON_FORMAT)format
{
    id result = nil;
    id tmp = [dic objectForKey:value];
    RelationMetadata *relation = [self getRelationMapForKey:key];
    if (relation) {
        SimpleJSONObjectMapping *map = relation.map;
        NSError *error = nil;
        if (map && tmp && [tmp isKindOfClass:[NSDictionary class]]) {
            result = [map objectWithDic:tmp class:relation._class format:format error:&error];
        }
    }
    return result;
}

- (nullable id) getRelationMapForKey:(NSString*)key
{
    for (RelationMetadata *meta in self.relations) {
        if ([meta.key isEqualToString:key]) {
            return meta;
        }
    }
    
    return nil;
}

- (BOOL) existMapping:(NSString*)key
{
    if (self.mapping && self.mapping.count > 0) {
        if ([self.mapping objectForKey:key]) {
            return YES;
        }
    }
    return NO;
}

- (NSString*)extractType:(NSString*)attribute
{
    NSString *str = @"_";
    
    NSRange first = [attribute rangeOfString:@"\""];
    if (first.location != NSNotFound && first.length != 0) {
        NSRange type = NSMakeRange(first.location + 1, [attribute rangeOfString:@"\"" options:0 range:NSMakeRange(first.location + 1, attribute.length - first.location - 1)].location - first.location - 1);
        @try {
            str = [attribute substringWithRange:type];
        }
        @catch (NSException *exception) {
            
        }
    }
    
    return str;
}

- (NSArray*) buildProperties:(Class)_class forceRebuild:(BOOL)force
{
    if (force || self.attributes.count == 0) {
        unsigned int propertyCount = 0;
        objc_property_t * properties = class_copyPropertyList(_class, &propertyCount);
        
        for (unsigned int i = 0; i < propertyCount; ++i) {
            objc_property_t property = properties[i];
            const char * name = property_getName(property);
            const char * attr = property_getAttributes(property);
            NSString *tmp = [NSString stringWithUTF8String:attr];
            NSString *tmpName = [NSString stringWithUTF8String:name];
            if (![self isExcluded:tmpName]) {
                AttributeMetadata *meta = [[AttributeMetadata alloc] initWithName:tmpName type:[self extractType:tmp]];
                [self.attributes addObject:meta];
            }
        }
        free(properties);
    }
    return self.attributes;
}

- (NSString*) mappingStandardName:(nonnull NSString*)name format:(SIMPLE_JSON_FORMAT)format
{
    NSString *tmp = nil;
    switch (format) {
        case SIMPLE_JSON_FORMAT_NONE:
            tmp = name;
            break;
            
        case SIMPLE_JSON_FORMAT_STANDARD:
        {
            NSArray *words = [name componentsSeparatedByString:@"_"];
            NSMutableString *str = [[NSMutableString alloc] init];
            
            for (int i=0; i<words.count; i++) {
                if (i == 0) {
                    [str appendString:[words objectAtIndex:i]];
                } else {
                    NSString *tmp = [words objectAtIndex:i];
                    NSString *first = [tmp substringToIndex:1];
                    [str appendString:[[first uppercaseString] stringByAppendingString:[tmp substringFromIndex:1]]];
                }
            }
            tmp = str;
        }
            break;
            
        default:
            tmp = name;
            break;
    }
    return tmp;
}

- (NSString*) getMappingKey:(nonnull NSString*)name format:(SIMPLE_JSON_FORMAT)format
{
    NSString *tmp = nil;

    // check additional mapping
    if ([self existMapping:name]) {
        tmp = [self.mapping objectForKey:name];
    } else {
        // then, default format mapping
        switch (format) {
            case SIMPLE_JSON_FORMAT_NONE:
                tmp = name;
                break;
                
            case SIMPLE_JSON_FORMAT_STANDARD:
            {
                NSMutableString *str = [[NSMutableString alloc] init];
                
                for (int i=0; i<name.length; i++) {
                    BOOL isUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[name characterAtIndex:i]];
                    if (isUppercase) {
                        [str appendString:@"_"];
                        [str appendString:[[name substringWithRange:NSMakeRange(i, 1)] lowercaseString]];
                    } else {
                        [str appendString:[name substringWithRange:NSMakeRange(i, 1)]];
                    }
                }
                tmp = str;
            }
                break;
                
            default:
                tmp = name;
                break;
        }
    }
    
    return tmp;
}

- (id)getObjectWithKey:(NSString*)key fromDic:(NSDictionary*)dic
{
    id result = dic;
    
    if ([key rangeOfString:@"/"].location != NSNotFound) {
        NSArray *arr = [key componentsSeparatedByString:@"/"];
        for (int i=0; i<arr.count; i++) {
            if (i < arr.count -1 ) {
                // loop into nested dic
                if (result && [result isKindOfClass:[NSDictionary class]]) {
                    result = [result objectForKey:[arr objectAtIndex:i]];
                } else {
                    result = nil;
                }
            } else {
                key = [arr objectAtIndex:i];
            }
        }
    }
    
    return result;
}

- (id) objectWithDic:(NSDictionary *)dic class:(__unsafe_unretained Class)_class format:(SIMPLE_JSON_FORMAT)format error:(NSError *__autoreleasing *)error
{
    // build properties list of class
    [self buildProperties:_class forceRebuild:NO];
    
    NSString *key = nil;
    id obj = [[_class alloc] init];
    NSDictionary *tmpDic = nil;
    
    // mapping
    @try {
        for (AttributeMetadata *meta in self.attributes) {
            // find dictionary and key
            key = [self getMappingKey:meta.name format:format];
            tmpDic = [self getObjectWithKey:key fromDic:dic];
            
            if (!tmpDic) {
                continue;
            }
            
            // do mapping
            if ([self isSafeForMapping:meta.type]) {
                // primitive type
                if ([tmpDic objectForKey:key]) {
                    [obj setValue:[tmpDic objectForKey:key] forKey:meta.name];
                }
            } else if ([meta.type isEqualToString:@"NSDate"]) {
                // date object
                if (self.formater && [tmpDic objectForKey:key]) {
                    NSDate *date = [self.formater dateFromString:[tmpDic objectForKey:key]];
                    if (date) {
                        [obj setValue:date forKey:meta.name];
                    }
                }
            } else if ([meta.type isEqualToString:@"NSArray"] || [meta.type isEqualToString:@"NSMutableArray"]) {
                // objects list
                NSMutableArray *arr = [self getMappingValueForArray:meta.name value:key from:tmpDic format:format];
                if (arr && ([arr isKindOfClass:[NSArray class]] || [arr isKindOfClass:[NSMutableArray class]])) {
                    [obj setValue:arr forKey:meta.name];
                }
            } else {
                // single object
                id tmpObj = [self getMappingValueForObject:meta.name value:key from:tmpDic format:format];
                RelationMetadata *relation = [self getRelationMapForKey:key];
                if (tmpObj && [tmpDic isKindOfClass:relation.class]) {
                    [obj setValue:tmpObj forKey:meta.name];
                }
            }
        }
    }
    @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:@"json to object" code:1 userInfo:exception.userInfo];
        obj = nil;
    }
    return obj;
}

- (id) JSONWithObject:(id)object format:(SIMPLE_JSON_FORMAT)format error:(NSError *__autoreleasing *)error
{
    [self buildProperties:[object class] forceRebuild:NO];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSString *key = nil;
    @try {
        for (AttributeMetadata *meta in self.attributes) {
            key = [self getMappingKey:meta.name format:format];
            
            if ([object valueForKey:meta.name]) {
                // do mapping
                if ([self isSafeForMapping:meta.type]) {
                    // primitive type
                    [dic setObject:[object valueForKey:meta.name] forKey:key];
                } else if ([meta.type isEqualToString:@"NSDate"]) {
                    // date object
                    NSDate *objDate = [object valueForKey:meta.name];
                    if (self.formater && objDate && [objDate isKindOfClass:[NSDate class]]) {
                        NSString *date = [self.formater stringFromDate:objDate];
                        if (date) {
                            [dic setValue:date forKey:key];
                        }
                    }
                } else if ([meta.type isEqualToString:@"NSArray"] || [meta.type isEqualToString:@"NSMutableArray"]) {
                    // objects list
                    NSMutableArray *arr = [[NSMutableArray alloc] init];
                    NSArray *tmp = [object valueForKey:meta.name];
                    RelationMetadata *relation = [self getRelationMapForKey:meta.name];
                    if (relation) {
                        for (id obj in tmp) {
                            SimpleJSONObjectMapping *mapper = relation.map;
                            NSDictionary *tmpDic = [mapper JSONWithObject:obj format:format error:error];
                            if (tmpDic) {
                                [arr addObject:tmpDic];
                            }
                        }
                    }
                    [dic setObject:arr forKey:key];
                } else {
                    // single object
                    RelationMetadata *relation = [self getRelationMapForKey:meta.name];
                    id obj = [object objectForKey:meta.name];
                    if (relation) {
                        SimpleJSONObjectMapping *mapper = relation.map;
                        NSDictionary *tmpDic = [mapper JSONWithObject:obj format:format error:error];
                        if (tmpDic) {
                            [dic setObject:tmpDic forKey:key];
                        }
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:@"object to json" code:2 userInfo:exception.userInfo];
        dic = nil;
    }
    return dic;
}
@end
