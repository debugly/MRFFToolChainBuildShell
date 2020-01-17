#
# Be sure to run `pod lib lint MRLamePod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MRLamePod'
  s.version          = '3.100'
  s.summary          = 'A short description of MRLamePod.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/qianlongxu/MRLamePod'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'qianlongxu' => 'qianlongxu@sohu-inc.com' }
  s.source           = { :http => "https://raw.githubusercontent.com/debugly/MRFFToolChainPod/master/MRLamePod-iOS-#{s.version}.zip" }

  s.ios.deployment_target = '8.0'
  s.ios.preserve_paths = "MRLamePod/iOS/Lame-#{s.version}/include"
  s.ios.header_mappings_dir = "MRLamePod/iOS/Lame-#{s.version}/include"
  s.ios.source_files = "MRLamePod/iOS/Lame-#{s.version}/include/*.h"
  s.ios.vendored_libraries = "MRLamePod/iOS/Lame-#{s.version}/lib/*.a"
  s.ios.public_header_files = "MRLamePod/iOS/Lame-#{s.version}/include/**/*.h"

end
