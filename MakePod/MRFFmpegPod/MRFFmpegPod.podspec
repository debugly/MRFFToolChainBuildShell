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
# libavdevice = 'libavdevice'
# libavfilter = 'libavfilter'

NAME='FFmpeg'
VER='3.4.7'

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
  s.source           = { :http => "https://qipai.56.com/dev/ifox/ffpods/#{s.name}-iOS-#{s.version}.zip" }
  s.ios.deployment_target = '8.0'
  
  # preserve sub folder structure
  s.ios.preserve_paths = "#{s.name}/iOS/#{NAME}-#{s.version}/include"
  s.ios.header_mappings_dir = "#{s.name}/iOS/#{NAME}-#{s.version}/include"

  s.subspec libavcodec do |sub|
    sub.ios.source_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libavcodec}/*.h"
    sub.ios.vendored_libraries = "#{s.name}/iOS/#{NAME}-#{s.version}/lib/#{libavcodec}.a"
    sub.ios.public_header_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libavcodec}/*.h"
  end
  
  s.subspec libavformat do |sub|
    sub.ios.source_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libavformat}/*.h"
    sub.ios.vendored_libraries = "#{s.name}/iOS/#{NAME}-#{s.version}/lib/#{libavformat}.a"
    sub.ios.public_header_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libavformat}/*.h"
  end

  s.subspec libavutil do |sub|
    sub.ios.source_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libavutil}/*.h"
    sub.ios.vendored_libraries = "#{s.name}/iOS/#{NAME}-#{s.version}/lib/#{libavutil}.a"
    sub.ios.public_header_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libavutil}/*.h"
  end

  s.subspec libswresample do |sub|
    sub.ios.source_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libswresample}/*.h"
    sub.ios.vendored_libraries = "#{s.name}/iOS/#{NAME}-#{s.version}/lib/#{libswresample}.a"
    sub.ios.public_header_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libswresample}/*.h"
  end

  s.subspec libswscale do |sub|
    sub.ios.source_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libswscale}/*.h"
    sub.ios.vendored_libraries = "#{s.name}/iOS/#{NAME}-#{s.version}/lib/#{libswscale}.a"
    sub.ios.public_header_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libswscale}/*.h"
  end
  
  # s.subspec libavdevice do |sub|
  #   sub.ios.source_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libavdevice}/*.h"
  #   sub.ios.vendored_libraries = "#{s.name}/iOS/#{NAME}-#{s.version}/lib/#{libavdevice}.a"
  #   sub.ios.public_header_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libavdevice}/*.h"
  # end

  # s.subspec libavfilter do |sub|
  #   sub.ios.source_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libavfilter}/*.h"
  #   sub.ios.vendored_libraries = "#{s.name}/iOS/#{NAME}-#{s.version}/lib/#{libavfilter}.a"
  #   sub.ios.public_header_files = "#{s.name}/iOS/#{NAME}-#{s.version}/include/#{libavfilter}/*.h"
  # end

  # s.ios.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Headers/Public"' } 
  # s.ios.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/#{s.name}/iOS/#{NAME}-' + s.version.to_s + '/include"' }
  
  # s.resource_bundles = {
  #   '#{s.name}' => ['#{s.name}/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.library = 'z', 'bz2', 'iconv', 'lzma'
  s.frameworks = 'CoreFoundation', 'CoreVideo', 'VideoToolbox', 'CoreMedia', 'AudioToolbox', 'Security'
  # other_ldflags = '$(inherited) -framework "VideoDecodeAcceleration"'
  # s.osx.xcconfig = {
  #   'OTHER_LDFLAGS[arch=arm64]' => other_ldflags
  # }

  # s.dependency 'AFNetworking', '~> 2.3'
end