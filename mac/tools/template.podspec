#
# Be sure to run `pod lib lint MRFFmpegPod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "__PODNAME__"
  s.version          = "__PODVER__"
  s.summary          = "A Pod Warper for __INC_NAME__ lib."
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
  s.author           = { 'qianlongxu' => 'qianlongxu@gmail.com' }
  s.source           = { :http => "__BINARY_SRC__" }
  
  s.osx.deployment_target = '10.11'

  # preserve sub folder structure
  # https://stackoverflow.com/questions/18373760/cocoapods-podspec-preserve-paths
  # s.osx.preserve_paths = "#{s.name}/macOS/#{s.version}/include"
  # s.osx.header_mappings_dir = "#{s.name}/macOS/#{s.version}/include"

  s.osx.source_files = "#{s.name}/macOS/#{s.version}/include/__INC_NAME__/*.h"
  s.osx.vendored_libraries = "#{s.name}/macOS/#{s.version}/lib/*.a"

end