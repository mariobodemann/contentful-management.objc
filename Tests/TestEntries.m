//
//  TestEntries.m
//  ManagementSDK
//
//  Created by Boris Bügling on 23/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

#import "BBURecordingHelper.h"
#import "CMASpace+Private.h"

SpecBegin(Entry)

describe(@"Entry", ^{
    __block CMAClient* client;
    __block CMAContentType* contentType;
    __block CMASpace* space;

    RECORD_TESTCASE

    beforeEach(^AsyncBlock {
        NSString* token = [[[NSProcessInfo processInfo] environment]
                           valueForKey:@"CONTENTFUL_MANAGEMENT_API_ACCESS_TOKEN"];

        client = [[CMAClient alloc] initWithAccessToken:token];

        [client fetchSpaceWithIdentifier:@"hvjkfbzcwrfn"
                                 success:^(CDAResponse *response, CMASpace *mySpace) {
                                     expect(mySpace).toNot.beNil();
                                     space = mySpace;

                                     [space fetchContentTypesWithSuccess:^(CDAResponse *response,
                                                                           CDAArray *array) {
                                         expect(array).toNot.beNil();
                                         expect(array.items.count).to.equal(13);

                                         for (CMAContentType* ct in array.items) {
                                             if ([ct.identifier isEqualToString:@"6FxqhReTPUuYAYW8gqOwS"]) {
                                                 contentType = ct;
                                                 break;
                                             }
                                         }

                                         expect(contentType.identifier).toNot.beNil();

                                         done();
                                     } failure:^(CDAResponse *response, NSError *error) {
                                         XCTFail(@"Error: %@", error);

                                         done();
                                     }];
                                 } failure:^(CDAResponse *response, NSError *error) {
                                     XCTFail(@"Error: %@", error);

                                     done();
                                 }];
    });

    it(@"can be archived", ^AsyncBlock {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                             withFields:@{}
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    expect(entry.isArchived).to.beFalsy();

                                    [entry archiveWithSuccess:^{
                                        expect(entry.sys[@"archivedVersion"]).equal(@1);
                                        expect(entry.isArchived).to.beTruthy();

                                        done();
                                    } failure:^(CDAResponse *response, NSError *error) {
                                        XCTFail(@"Error: %@", error);

                                        done();
                                    }];
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);
                                    
                                    done();
                                }];
    });

    it(@"can be created", ^AsyncBlock {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                             withFields:@{ @"title": @{ @"en-US": @"Mr. President" } }
                                success:^(CDAResponse *response, CDAEntry *entry) {
                                    expect(entry).toNot.beNil();

                                    expect(entry.identifier).toNot.beNil();
                                    expect(entry.sys[@"version"]).equal(@1);
                                    expect(entry.fields[@"title"]).equal(@"Mr. President");

                                    done();
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);

                                    done();
                                }];
    });

    it(@"can be created with user-defined identifier", ^AsyncBlock {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                         withIdentifier:@"foo"
                                 fields:@{}
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    expect(entry).toNot.beNil();

                                    expect(entry.identifier).equal(@"foo");
                                    expect(entry.sys[@"version"]).equal(@1);

                                    [entry deleteWithSuccess:^{
                                        done();
                                    } failure:^(CDAResponse *response, NSError *error) {
                                        XCTFail(@"Error: %@", error);

                                        done();
                                    }];
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);

                                    done();
                                }];
    });

    it(@"can be deleted", ^AsyncBlock {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                             withFields:@{}
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    expect(entry).toNot.beNil();

                                    [entry deleteWithSuccess:^{
                                        [NSThread sleepForTimeInterval:5.0];

                                        [space fetchEntryWithIdentifier:entry.identifier
                                                                success:^(CDAResponse *response,
                                                                          CDAEntry *entry) {
                                                                    XCTFail(@"Should not succeed.");

                                                                    done();
                                                                } failure:^(CDAResponse *response,
                                                                            NSError *error) {
                                                                    done();
                                                                }];
                                    } failure:^(CDAResponse *response, NSError *error) {
                                        XCTFail(@"Error: %@", error);

                                        done();
                                    }];
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);

                                    done();
                                }];
    });

    it(@"can be published", ^AsyncBlock {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                             withFields:@{}
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    expect(entry.isPublished).to.equal(NO);

                                    [entry publishWithSuccess:^{
                                        expect(entry.sys[@"publishedCounter"]).equal(@1);
                                        expect(entry.isPublished).to.equal(YES);

                                        done();
                                    } failure:^(CDAResponse *response, NSError *error) {
                                        XCTFail(@"Error: %@", error);

                                        done();
                                    }];
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);

                                    done();
                                }];
    });

    it(@"can be unarchived", ^AsyncBlock {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                             withFields:@{}
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    [entry archiveWithSuccess:^{
                                        expect(entry.sys[@"archivedVersion"]).equal(@1);

                                        [entry unarchiveWithSuccess:^{
                                            expect(entry.sys[@"archivedVersion"]).to.beNil();

                                            done();
                                        } failure:^(CDAResponse *response, NSError *error) {
                                            XCTFail(@"Error: %@", error);

                                            done();
                                        }];
                                    } failure:^(CDAResponse *response, NSError *error) {
                                        XCTFail(@"Error: %@", error);

                                        done();
                                    }];
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);
                                    
                                    done();
                                }];
    });

    it(@"can be unpublished", ^AsyncBlock {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                             withFields:@{}
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    [entry publishWithSuccess:^{
                                        expect(entry.sys[@"publishedVersion"]).equal(@1);

                                        [entry unpublishWithSuccess:^{
                                            expect(entry.sys[@"publishedVersion"]).to.beNil();

                                            done();
                                        } failure:^(CDAResponse *response, NSError *error) {
                                            XCTFail(@"Error: %@", error);

                                            done();
                                        }];
                                    } failure:^(CDAResponse *response, NSError *error) {
                                        XCTFail(@"Error: %@", error);

                                        done();
                                    }];
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);
                                    
                                    done();
                                }];
    });

    it(@"can set a location value", ^AsyncBlock {
        NSAssert(space, @"Test space could not be found.");

        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(40.0, 50.0);
        NSData* locationData = [NSData dataWithBytes:&location length:sizeof(location)];

        [space createEntryOfContentType:contentType
                             withFields:@{ @"location": @{ @"en-US": locationData } }
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    expect(entry).toNot.beNil();
                                    expect([entry CLLocationCoordinate2DFromFieldWithIdentifier:@"location"]).to.equal(location);

                                    done();
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);

                                    done();
                                }];
    });

    it(@"can be updated", ^AsyncBlock {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                             withFields:@{ @"title": @{ @"en-US": @"foo" } }
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    expect(entry).toNot.beNil();

                                    [entry setValue:@"bar" forFieldWithName:@"title"];
                                    [entry updateWithSuccess:^{
                                        [NSThread sleepForTimeInterval:4.0];

                                        [space fetchEntryWithIdentifier:entry.identifier success:^  (CDAResponse *response, CDAEntry *newEntry) {
                                            expect(entry.fields[@"title"]).equal(@"bar");
                                            expect(entry.sys[@"version"]).equal(@2);

                                            expect(newEntry).toNot.beNil();
                                            expect(newEntry.fields[@"title"]).equal(@"bar");
                                            expect(newEntry.sys[@"version"]).equal(@2);

                                            done();
                                        } failure:^(CDAResponse *response, NSError *error) {
                                            XCTFail(@"Error: %@", error);

                                            done();
                                        }];
                                    } failure:^(CDAResponse *response, NSError *error) {
                                        XCTFail(@"Error: %@", error);

                                        done();
                                    }];
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);

                                    done();
                                }];
    });
});

SpecEnd
