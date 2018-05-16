#
# Be sure to run `pod lib lint Macaw.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Macaw"
  s.version          = "0.9.2"
  s.summary          = "Powerful and easy-to-use vector graphics library with SVG support written in Swift."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
#  s.description      = <<-DESC
#                       DESC

  s.homepage         = 'https://github.com/exyte/Macaw.git'
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { 'Igor Zapletnev' => 'igor.zapletnev@gmail.com' }
  s.source           = { :git => 'https://github.com/exyte/Macaw.git', :tag => s.version.to_s }
  s.social_media_url = 'http://exyte.com'

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.12"
  s.requires_arc = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }

  s.source_files = [
     'Source/**/*.swift'
  ]
  # s.resource_bundles = {
  #   'Macaw' => ['Pod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SWXMLHash' 
end
