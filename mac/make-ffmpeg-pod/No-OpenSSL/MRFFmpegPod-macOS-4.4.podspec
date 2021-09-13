#
# Be sure to run `pod lib lint MRFFmpegPod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

libavcodec = 'libavcodec'
libavformat = 'libavformat'
libavutil = 'libavutil'
libswresample = 'libswresample'
libswscale = 'libswscale'
libavdevice = 'libavdevice'
libavfilter = 'libavfilter'

NAME='FFmpeg'
VER='4.4'

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
  s.source           = { :http => "https://ifoxdev.hd.sohu.com/ffpods/20210913/MRFFmpegPod-macOS-#{s.version}.zip" }

  s.osx.deployment_target = '10.11'

  s.osx.preserve_paths = "#{s.name}/macOS/#{s.version}/include"
  s.osx.header_mappings_dir = "#{s.name}/macOS/#{s.version}/include"

  s.subspec libavcodec do |sub|
    sub.osx.source_files = "#{s.name}/macOS/#{s.version}/include/#{libavcodec}/*.h"
    sub.osx.vendored_libraries = "#{s.name}/macOS/#{s.version}/lib/#{libavcodec}.a"
    sub.osx.public_header_files = "#{s.name}/macOS/#{s.version}/include/#{libavcodec}/*.h"
  end
  
  s.subspec libavformat do |sub|
    sub.osx.source_files = "#{s.name}/macOS/#{s.version}/include/#{libavformat}/*.h"
    sub.osx.vendored_libraries = "#{s.name}/macOS/#{s.version}/lib/#{libavformat}.a"
    sub.osx.public_header_files = "#{s.name}/macOS/#{s.version}/include/#{libavformat}/*.h"
  end

  s.subspec libavutil do |sub|
    sub.osx.source_files = "#{s.name}/macOS/#{s.version}/include/#{libavutil}/*.h"
    sub.osx.vendored_libraries = "#{s.name}/macOS/#{s.version}/lib/#{libavutil}.a"
    sub.osx.public_header_files = "#{s.name}/macOS/#{s.version}/include/#{libavutil}/*.h"
  end

  s.subspec libswresample do |sub|
    sub.osx.source_files = "#{s.name}/macOS/#{s.version}/include/#{libswresample}/*.h"
    sub.osx.vendored_libraries = "#{s.name}/macOS/#{s.version}/lib/#{libswresample}.a"
    sub.osx.public_header_files = "#{s.name}/macOS/#{s.version}/include/#{libswresample}/*.h"
  end

  s.subspec libswscale do |sub|
    sub.osx.source_files = "#{s.name}/macOS/#{s.version}/include/#{libswscale}/*.h"
    sub.osx.vendored_libraries = "#{s.name}/macOS/#{s.version}/lib/#{libswscale}.a"
    sub.osx.public_header_files = "#{s.name}/macOS/#{s.version}/include/#{libswscale}/*.h"
  end
  
  s.subspec libavdevice do |sub|
    sub.osx.source_files = "#{s.name}/macOS/#{s.version}/include/#{libavdevice}/*.h"
    sub.osx.vendored_libraries = "#{s.name}/macOS/#{s.version}/lib/#{libavdevice}.a"
    sub.osx.public_header_files = "#{s.name}/macOS/#{s.version}/include/#{libavdevice}/*.h"
    
  end

  s.subspec libavfilter do |sub|
    sub.osx.source_files = "#{s.name}/macOS/#{s.version}/include/#{libavfilter}/*.h"
    sub.osx.vendored_libraries = "#{s.name}/macOS/#{s.version}/lib/#{libavfilter}.a"
    sub.osx.public_header_files = "#{s.name}/macOS/#{s.version}/include/#{libavfilter}/*.h"
  end

  s.library = 'z', 'bz2', 'iconv', 'lzma'
  s.frameworks = 'CoreFoundation', 'CoreVideo', 'VideoToolbox', 'CoreMedia', 'AudioToolbox', 'Security'
  # other_ldflags = '$(inherited) -framework "VideoDecodeAcceleration"'
  # s.osx.xcconfig = {
  #   'OTHER_LDFLAGS[arch=arm64]' => other_ldflags
  # }
end