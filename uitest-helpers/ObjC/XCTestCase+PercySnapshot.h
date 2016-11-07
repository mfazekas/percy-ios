//
//  XCTestCase+PercySnapshot.h
//
//  Created by Miklos Fazekas on 30/10/16.
//  Copyright © 2016 Miklos Fazekas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@interface XCTestCase (PercySnapshot)
- (void)percySnapshotWithPath:(NSString*)path;
@end
