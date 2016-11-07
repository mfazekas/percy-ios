Pod::Spec.new do |s|
  s.name = 'percy-ios'
  s.version = '1.0.0.alpha'
  s.license = { type: "MIT", file: 'LICENSE' }
  s.summary = 'Continous visual integration for iOS apps'
  s.homepage = 'https://github.com/mfazekas/percy-ios'
  s.authors = { 'Miklós Fazekas' => 'mfazekas@szemafor.com' }
  s.source = { path: "/Work/Freelance/Ruby/Percy/percy-ios" }

  s.ios.deployment_target = '9.0'

  s.default_subspecs = []

  s.subspec 'objc-uitest-helper' do |sp|
    sp.source_files = "uitest-helpers/ObjC/XCTestCase+PercySnapshot.{h,m}"
    sp.frameworks = ["XCTest"]
  end

  s.subspec 'swift-uitest-helper' do |sp|
    sp.source_files = "uitest-helpers/Swift/XCTestCase+PercySnapshot.swift"
    sp.frameworks = ["XCTest"]
  end
end
