#include "test.h"
#include <stdio.h>
#include <libavutil/avutil.h>

void say(void)
{
    printf("FFmpeg: %s\n", av_version_info());
}
