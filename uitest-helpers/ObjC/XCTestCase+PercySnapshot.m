//
//  XCTestCase+PercySnapshot.m
//
//  Created by Miklos Fazekas on 30/10/16.
//  Copyright © 2016 Miklos Fazekas. All rights reserved.
//

#import "XCTestCase+PercySnapshot.h"

@interface XCTestCase()
- (void) startActivityWithTitle:(NSString*) title block:(void (^)(void)) block;
@end

@interface XCUIApplication()
- (void) _waitForQuiescence;
@end

@implementation XCTestCase (PercySnapshot)
- (void) percySnapshotWithPath: (NSString*) path
{
    [self startActivityWithTitle:[NSString stringWithFormat:@"io.percy/%@", path] block:^{
        XCUIApplication* app = [[XCUIApplication alloc] init];
        [app _waitForQuiescence];
    }];
}
@end
