/* Compile/link probe only: this is not a device codec-capability test. */
#include <multimedia/player_framework/native_avcodec_videodecoder.h>
#include <multimedia/player_framework/native_avcodec_videoencoder.h>

int ohos_sdk_smoke(void)
{
    OH_AVCodec *decoder = OH_VideoDecoder_CreateByMime("video/avc");
    OH_AVCodec *encoder = OH_VideoEncoder_CreateByMime("video/avc");
    if (decoder)
        OH_VideoDecoder_Destroy(decoder);
    if (encoder)
        OH_VideoEncoder_Destroy(encoder);
    return decoder != 0 && encoder != 0;
}
