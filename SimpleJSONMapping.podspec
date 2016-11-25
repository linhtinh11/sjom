#
# Be sure to run `pod lib lint SimpleJSONOMapping.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SimpleJSONMapping'
  s.version          = '0.1.1'
  s.summary          = 'simple way to map json to object and viceversa'

  s.homepage         = 'https://github.com/linhtinh11/sjom'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'linhtinh11' => 'linhtinh11@gmail.com' }
  s.source           = { :git => 'https://github.com/linhtinh11/sjom.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'SimpleJSONMapping/SimpleJSONMapping/**/*'
  
  # s.resource_bundles = {
  #   'SimpleJSONMapping' => ['SimpleJSONMapping/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.requires_arc     = true
end
