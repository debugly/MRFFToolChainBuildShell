#
# Be sure to run `pod lib lint MRFFmpegPod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

libavcodec = 'libavcodec'
libavdevice = 'libavdevice'
libavfilter = 'libavfilter'
libavformat = 'libavformat'
libavutil = 'libavutil'
libswresample = 'libswresample'
libswscale = 'libswscale'

Pod::Spec.new do |s|
  s.name             = 'MRFFmpegPod'
  s.version          = '4.2.2'
  s.summary          = 'A short description of MRFFmpegPod.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/qianlongxu/MRFFmpegPod'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :text => 'MIT LICENSE' }
  s.author           = { 'qianlongxu' => 'qianlongxu@gmial.com' }
  s.source           = { :http => 'http://localhost/test/MRFFmpegPod.zip' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  
  # preserve sub folder structure
  s.ios.preserve_paths = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include"
  s.ios.header_mappings_dir = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include"

  s.subspec libavcodec do |sub|
    sub.ios.source_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libavcodec}/*.h"
    sub.ios.vendored_libraries = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/lib/#{libavcodec}.a"
    sub.ios.public_header_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libavcodec}/*.h"
  end
  
  # s.subspec libavdevice do |sub|
  #   sub.ios.source_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libavdevice}/*.h"
  #   sub.ios.vendored_libraries = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/lib/#{libavdevice}.a"
  #   sub.ios.public_header_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libavdevice}/*.h"
  # end

  s.subspec libavfilter do |sub|
    sub.ios.source_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libavfilter}/*.h"
    sub.ios.vendored_libraries = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/lib/#{libavfilter}.a"
    sub.ios.public_header_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libavfilter}/*.h"
  end

  s.subspec libavformat do |sub|
    sub.ios.source_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libavformat}/*.h"
    sub.ios.vendored_libraries = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/lib/#{libavformat}.a"
    sub.ios.public_header_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libavformat}/*.h"
  end

  s.subspec libavutil do |sub|
    sub.ios.source_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libavutil}/*.h"
    sub.ios.vendored_libraries = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/lib/#{libavutil}.a"
    sub.ios.public_header_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libavutil}/*.h"
  end

  s.subspec libswresample do |sub|
    sub.ios.source_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libswresample}/*.h"
    sub.ios.vendored_libraries = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/lib/#{libswresample}.a"
    sub.ios.public_header_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libswresample}/*.h"
  end

  s.subspec libswscale do |sub|
    sub.ios.source_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libswscale}/*.h"
    sub.ios.vendored_libraries = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/lib/#{libswscale}.a"
    sub.ios.public_header_files = "MRFFmpegPod/iOS/FFmpeg-#{s.version}/include/#{libswscale}/*.h"
  end
  
  # s.ios.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/Headers/Public"' } 
  # s.ios.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/MRFFmpegPod/iOS/FFmpeg-' + s.version.to_s + '/include"' }
  
  # s.resource_bundles = {
  #   'MRFFmpegPod' => ['MRFFmpegPod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.library = 'z', 'bz2', 'iconv', 'lzma'
  s.frameworks = 'CoreFoundation', 'CoreVideo', 'VideoToolbox', 'CoreMedia', 'AudioToolbox', 'Security'
  other_ldflags = '$(inherited) -framework "VideoDecodeAcceleration"'
  s.ios.xcconfig = {
    'OTHER_LDFLAGS[arch=arm64]' => other_ldflags
  }

  # s.dependency 'AFNetworking', '~> 2.3'
end
