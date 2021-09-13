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
  s.source           = { :http => "https://ifoxdev.hd.sohu.com/ffpods/20210913/MROpenSSLPod-macOS-#{s.version}.zip" }
  
  s.osx.deployment_target = '10.11'

  # preserve sub folder structure
  s.osx.preserve_paths = "#{s.name}/macOS/#{s.version}/include"
  s.osx.header_mappings_dir = "#{s.name}/macOS/#{s.version}/include"

  s.osx.source_files = "#{s.name}/macOS/#{s.version}/include/openssl/*.h"
  s.osx.vendored_libraries = "#{s.name}/macOS/#{s.version}/lib/*.a"

end