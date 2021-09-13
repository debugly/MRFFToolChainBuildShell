# MRFFmpegPod

```
# 将编译好的依赖 openssl 的 ffmpeg 库复制到 ./MRFFmpegPod/macOS 目录下，然后打成 zip 包
./make-pod.sh 4.4 openssl

# 将编译好的不依赖 openssl 的 ffmpeg 库复制到 ./MRFFmpegPod/macOS 目录下，然后打成 zip 包
./make-pod.sh 4.4

# 传到服务器上
scp ./MRFFmpegPod-macOS-4.4-openssl.podspec root@101.181.120.119:/data/ifox/ffpods/20210913
scp ./MRFFmpegPod-macOS-4.4-openssl.zip root@101.181.120.119:/data/ifox/ffpods/20210913
```