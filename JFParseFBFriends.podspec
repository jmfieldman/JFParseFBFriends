#
# Be sure to run `pod lib lint JFParseFBFriends.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JFParseFBFriends"
  s.version          = "1.0.0"
  s.summary          = "A CocoaPod to help manage Facebook/Parse friend relationships."
  s.description      = <<-DESC
                       Being able to quickly prototype social apps with Parse/Facebook is great.  One of the annoying tasks is managing the caching/update of the user's friend network.

                       This helper class is designed to streamline the management of your Parse PFUser's Facebook info, and use blocks to push seamless friend-list updates to your UI.
                       DESC
  s.homepage         = "https://github.com/jmfieldman/JFParseFBFriends"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Jason Fieldman" => "jason@fieldman.org" }
  s.source           = { :git => "https://github.com/jmfieldman/JFParseFBFriends.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'JFParseFBFriends' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Parse'
  s.dependency 'Facebook-iOS-SDK'
  s.dependency 'ParseFacebookUtils'
end
