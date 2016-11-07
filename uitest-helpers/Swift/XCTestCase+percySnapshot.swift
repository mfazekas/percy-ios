//
//  XCTestCase+percySnapshot.swift
//  ios-ci-sample
//
//  Created by Miklos Fazekas on 30/10/16.
//  Copyright © 2016 Miklos Fazekas. All rights reserved.
//

import Foundation
import XCTest

@objc protocol XCTestCasePrivate {
    typealias ObjCBlock = @convention(block) ()->Void
    @objc func startActivity(withTitle: String!, block:ObjCBlock) -> Void;
}

extension XCTestCase {
    public func percySnapshot(path: String) -> Void {
        (self as AnyObject).startActivity!(withTitle:"io.percy/\(path)", block:{() in
            let app = XCUIApplication()
            app.perform(Selector(("_waitForQuiescence")))
        })
    }
}
