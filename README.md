├── README.md
├── apple           #apple平台通用编译脚本
│   ├── compile-any.sh
│   ├── compile-cfgs
│   ├── do-compile
│   └── init-env.sh
├── build           #编译目录
│   ├── product     #编译产物
│   └── src         #构建时源码仓库
├── extra           #ffmpeg，openssl 等库的源码
│   ├── bluray
│   ├── dav1d
│   ├── ffmpeg
│   ├── libyuv
│   ├── openssl
│   ├── opus
│   └── patches     #打的补丁
├── ffconfig        #ffmpeg 功能裁剪配置
│   ├── configure.md
│   ├── module-default.sh
│   ├── module-full.sh
│   ├── module-lite-hevc.sh
│   ├── module-lite.sh
│   └── module.sh -> module-full.sh
├── init-any.sh     #初始化源码仓库
├── init-cfgs       #三方库的配置，包括库名，git仓库地址等信息
│   ├── bluray
│   ├── dav1d
│   ├── ffmpeg
│   ├── libyuv
│   ├── openssl
│   └── opus
├── ios             #ios 平台编译脚本
│   └── compile-any.sh
├── macos           #macos 平台编译脚本
│   └── compile-any.sh
└── tools           #初始化仓库依赖的脚本
    ├── copy-local-repo.sh
    ├── env_assert.sh
    ├── init-repo.sh
    ├── pull-repo-base.sh
    └── pull-repo-ref.sh
