//
//  BBURecordingHelper.m
//  ManagementSDK
//
//  Created by Boris Bügling on 30/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <CCLRequestReplay/CCLRequestJSONRecording.h>
#import <CCLRequestReplay/CCLRequestRecordProtocol.h>
#import <CCLRequestReplay/CCLRequestReplayProtocol.h>

#import "BBURecordingHelper.h"

@interface BBURecordingHelper ()

@property (nonatomic) CCLRequestReplayManager* manager;
@property (nonatomic, getter = isReplaying) BOOL replaying;

@end

#pragma mark -

@implementation BBURecordingHelper

+(instancetype)sharedHelper {
    static BBURecordingHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [self new];
    });
    return sharedHelper;
}

#pragma mark -

-(void)loadRecordingsForTestCase:(Class)testCase {
    NSBundle* bundle = [NSBundle bundleForClass:testCase];
    NSString* recordingPath = [bundle pathForResource:NSStringFromClass(testCase)
                                               ofType:@"recording"
                                          inDirectory:@"Recordings"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:recordingPath]) {
        self.manager = [NSKeyedUnarchiver unarchiveObjectWithFile:recordingPath];
        self.replaying = YES;

        CCLRequestJSONRecording* recording = [[CCLRequestJSONRecording alloc]
                                              initWithBundledJSONNamed:nil
                                              inDirectory:nil
                                              matcher:^BOOL(NSURLRequest *request) {
                                                  return YES;
                                              }
                                              statusCode:404
                                              headerFields:nil];
        [self.manager addRecording:recording];

        [self.manager replay];
    } else {
        self.manager = [CCLRequestReplayManager new];
        self.replaying = NO;
        
        [self.manager record];
    }
}

-(void)storeRecordingsForTestCase:(Class)testCase {
    [self.manager stopReplay];
    [self.manager stopRecording];

    NSString* recordingName = [NSStringFromClass(testCase) stringByAppendingPathExtension:@"recording"];
    NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:recordingName];
    BOOL result = [NSKeyedArchiver archiveRootObject:self.manager
                                              toFile:path];

    if (!result) {
        [NSException raise:NSInternalInconsistencyException format:@"Recording %@ could not be stored",
         path];
    }

    self.manager = nil;
}

@end
