#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_rongcloud_im'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter rongcloud im plugin.'
  s.description      = <<-DESC
A new Flutter rongcloud im plugin.
                       DESC
  s.homepage         = 'http://ninefrost.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.static_framework = true
  s.dependency 'Flutter'

  s.frameworks = ["AssetsLibrary", "AudioToolbox", "AVFoundation", "CFNetwork", "CoreAudio", "CoreGraphics", "CoreLocation", "CoreMedia", "CoreTelephony", "CoreVideo", "ImageIO", "MapKit", "OpenGLES", "QuartzCore", "SystemConfiguration", "UIKit", "Photos", "SafariServices"]
  s.libraries = ["c++", "c++abi", "sqlite3.0", "stdc++", "xml2", "z"]
  s.preserve_paths = "Libs/*.a"
  s.preserve_paths = "Libs/*.framework"
  s.vendored_libraries = "**/*.a"
  s.vendored_frameworks="**/*.framework"
  s.ios.deployment_target = "9.3"
end

