#ifndef MICRO_SPEECH_H_
#define MICRO_SPEECH_H_

#include "tensorflow/lite/core/c/common.h"

TfLiteStatus TestAudioSample(const char *label, const int16_t *audio_data,
                             const size_t audio_data_size);

#endif // MICRO_SPEECH_H_