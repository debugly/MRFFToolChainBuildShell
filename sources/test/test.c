#include "test.h"
#include <stdio.h>
#include <libavutil/avutil.h>
#include <ass/ass.h>

void say(void)
{
    unsigned int version = (unsigned int)ass_library_version();
    printf("FFmpeg: %s\n", av_version_info());
    /* libass stores the decimal version digits in hexadecimal nibbles. */
    printf("libass: %x.%x.%x\n", version >> 28,
           (version >> 20) & 0xff, (version >> 12) & 0xff);
}
