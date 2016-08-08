#
# Be sure to run `pod lib lint Macaw.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Macaw"
  s.version          = "0.1.0"
  s.summary          = "Swift UI Library"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
#  s.description      = <<-DESC
#                       DESC

  s.homepage         = 'https://github.com/exyte/Macaw'
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { 'Igor Zapletnev' => 'igor.zapletnev@gmail.com' }
  s.source           = { :git => 'https://github.com/exyte/Macaw.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = [
     'Source/*.swift',
     'Source/animation/*.swift',
     'Source/animation/layer_animation/*.swift',
     'Source/animation/layer_animation/utils/*.swift',
     'Source/animation/layer_animation/extensions/*.swift',
     'Source/animation/types/*.swift',
     'Source/animation/types/animation_generators/*.swift',
     'Source/animation/types/animation_generators/cache/*.swift',
     'Source/bindings/*.swift',
     'Source/events/*.swift',
     'Source/model/draw/*.swift',
     'Source/model/geom2d/*.swift',
     'Source/model/input/*.swift',
     'Source/model/scene/*.swift',
     'Source/render/*.swift',
     'Source/views/*.swift',
     'Source/svg/*.swift'
  ]
  # s.resource_bundles = {
  #   'Macaw' => ['Pod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SWXMLHash', '~> 2.3.0'
  s.dependency 'RxSwift'
  s.dependency 'Swift-CAAnimation-Closure', '~> 1.0'
end
