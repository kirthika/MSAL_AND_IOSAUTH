Pod::Spec.new do |s|
  s.name         = "ios-auth-library"
  s.version      = "0.0.1"
  s.summary      = "A small library providing methods to authenticate and authorize iOS apps against Azure B2C."
  s.description  = "This module provides a login workflow as well as an isAuthenticated check, as well as a means to store JWTs into cookies."
  s.homepage     = "http://www.toyota.com"
  s.license      = "MIT"
  s.author       = "Pariveda Solutions"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://bitbucket.org/parivedasolutions/ios-auth-library.git" }
  s.source_files  = "ios-auth-library", "ios-auth-library/**/*.{h,m,swift}"
  s.pod_target_xcconfig = { "SWIFT_VERSION" => '3' }
end