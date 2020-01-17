#
# Be sure to run `pod lib lint MRFdk-aacPod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

NAME='Fdk-aac'
VER='2.0.1'

Pod::Spec.new do |s|
  s.name             = "MR#{NAME}Pod"
  s.version          = "#{VER}"
  s.summary          = "A Pod Warper for #{NAME} lib."
  s.description      = <<-DESC
The pod is a member of MRFFToolChainPod.
What's MRFFToolChainPod?
MRFFToolChainPod is buid for my ffmepg tutorial : https://github.com/debugly/StudyFFmpeg .
MRFFToolChainPod contain FFmpeg lib, Lame lib,X264 lib,Fdk-aac lib...
Where's the build shell?
All ToolChain lib build shell is here : https://github.com/debugly/MRFFToolChain
                       DESC

  s.homepage         = 'https://github.com/debugly/MRFFToolChainPod/'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'qianlongxu' => 'qianlongxu@sohu-inc.com' }
  s.source           = { :http => "https://raw.githubusercontent.com/debugly/MRFFToolChainPod/master/#{s.name}-iOS-#{s.version}.zip" }
  s.ios.deployment_target = '8.0'
  
  s.ios.preserve_paths = "#{s.name}/iOS/#{NAME}-#{s.version}/include"
  s.ios.header_mappings_dir = "#{s.name}/iOS/#{NAME}-#{s.version}/include"
  s.ios.source_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/*.h"
  s.ios.vendored_libraries = "#{s.name}/iOS/#{NAME}-#{s.version}/lib/*.a"
  s.ios.public_header_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/**/*.h"

end
