#
# Be sure to run `pod lib lint Macaw.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Macaw"
  s.version          = "0.9.7"
  s.summary          = "Powerful and easy-to-use vector graphics library with SVG support written in Swift."

  s.homepage         = 'https://github.com/exyte/Macaw.git'
  s.license          = 'MIT'
  s.author           = { 'Exyte' => 'info@exyte.com' }
  s.source           = { :git => 'https://github.com/exyte/Macaw.git', :tag => s.version.to_s }
  s.social_media_url = 'http://exyte.com'

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.12"
  s.requires_arc = true
  s.swift_version = "5.3"

  s.source_files = [
     'Source/**/*.swift'
  ]

  s.dependency 'SWXMLHash'
end
