#
# Be sure to run `pod lib lint MRFFmpegPod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

NAME='OpenSSL'
VER='1.1.1l'

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
  s.author           = { 'qianlongxu' => 'qianlongxu@gmail.com' }
  s.source           = { :http => "https://ifoxdev.hd.sohu.com/ffpods/20210913/MROpenSSLPod-iOS-#{s.version}.zip" }
  
  s.ios.deployment_target = '9.0'
  
  s.ios.preserve_paths = "#{s.name}/iOS/#{s.version}/include"
  s.ios.header_mappings_dir = "#{s.name}/iOS/#{s.version}/include"

  s.ios.source_files = "#{s.name}/iOS/#{s.version}/include/openssl/*.h"
  s.ios.vendored_libraries = "#{s.name}/iOS/#{s.version}/lib/*.a"
end