//
//  SimpleJSONMappingTests.m
//  SimpleJSONMappingTests
//
//  Created by trung on 7/21/16.
//  Copyright © 2016 nws. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DBMetadata.h"
#import "SimpleJSONObjectMapping.h"

@interface SimpleJSONMappingTests : XCTestCase

@end

@implementation SimpleJSONMappingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testJSON {
    SimpleJSONObjectMapping *map = [[SimpleJSONObjectMapping alloc] init];
    NSError *error = nil;
//    NSDictionary *dic = @{@"size": @"225.4KB",
//                          @"rev": @"35e97029684fe",
//                          @"thumb_exists": [NSNumber numberWithBool:NO],
//                          @"bytes": [NSNumber numberWithInteger:230783],
//                          @"modified": @"Tue, 19 Jul 2011 21:55:38 +0000",
//                          @"client_mtime": @"Mon, 18 Jul 2011 18:04:35 +0000",
//                          @"path": @"/Getting_Started.pdf",
//                          @"is_dir": [NSNumber numberWithBool:YES],
//                          @"icon": @"page_white_acrobat",
//                          @"root": @"dropbox",
//                          @"mime_type": @"application/pdf",
//                          @"revision": [NSNumber numberWithInteger:220823],
//                          @"contents": @[@{
//                                             @"size": @"2.3 MB",
//                                             @"rev": @"38af1b183490",
//                                             @"thumb_exists": [NSNumber numberWithBool:YES],
//                                             @"bytes": [NSNumber numberWithInteger:230783],
//                                             @"modified": @"Mon, 07 Apr 2014 23:13:16 +0000",
//                                             @"client_mtime": @"Thu, 29 Aug 2013 01:12:02 +0000",
//                                             @"path": @"/Photos/flower.jpg",
//                                             @"is_dir": [NSNumber numberWithBool:NO],
//                                             @"icon": @"page_white_picture",
//                                             @"root": @"dropbox",
//                                             @"mime_type": @"image/jpeg"
//                                             }]
//                          };
    NSString *json = @"{\"contents\":[{\"modified\":\"Tue, 08 Apr 2014 06:13:16 +0700\",\"rev\":\"38af1b183490\",\"path\":\"/Photos/flower.jpg\",\"thumb_exists\":true,\"bytes\":\"asdf\",\"is_dir\":\"false\",\"icon\":\"page_white_picture\",\"root\":\"dropbox\",\"size\":\"2.3 MB\"}],\"modified\":\"Wed, 20 Jul 2011 04:55:38 +0700\",\"rev\":\"35e97029684fe\",\"path\":\"/Getting_Started.pdf\",\"thumb_exists\":false,\"is_dir\":\"asdf\",\"icon\":\"page_white_acrobat\",\"root\":\"dropbox\",\"size\":\"225.4KB\"}";
    NSData *jsonD = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonD options:NSJSONReadingMutableContainers error:nil];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    //    [formater setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formater setDateFormat:@"EEE',' dd MMM yyyy HH':'mm':'ss ZZZ"];
    [map setDateFormater:formater];
    [map addRelationMapping:@"contents" map:map class:[DBMetadata class]];
    DBMetadata *profile = [map objectWithDic:dic class:[DBMetadata class] format:SIMPLE_JSON_FORMAT_STANDARD error:&error];
    NSLog(@"dir: %i", profile.bytes.integerValue);
    
    // object to dic
    SimpleJSONObjectMapping *map2 = [[SimpleJSONObjectMapping alloc] init];
    [map2 setExcludeAttributes:@[@"bytes"]];
    [map2 setDateFormater:formater];
    [map2 addRelationMapping:@"contents" map:map2 class:[DBMetadata class]];
    NSDictionary *dic2 = [map2 JSONWithObject:profile format:SIMPLE_JSON_FORMAT_STANDARD error:&error];
    NSLog(@"%@", dic2);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic2
                                                       options:0
                                                         error:&error];
    NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    XCTAssert(profile, @"Pass");
}

@end
