#include "tensorflow/lite/micro/debug_log.h"
#include <printf.h>

extern "C" void DebugLog(const char *format, va_list args)
{
#ifndef TF_LITE_STRIP_ERROR_STRINGS
    // Reusing TF_LITE_STRIP_ERROR_STRINGS to disable DebugLog completely to get
    // maximum reduction in binary size. This is because we have DebugLog calls
    // via TF_LITE_CHECK that are not stubbed out by TF_LITE_REPORT_ERROR.
    vprintf(format, args);
#endif
}

extern "C" int DebugVsnprintf(char *buffer, size_t buf_size, const char *format,
                              va_list vlist)
{
#ifndef TF_LITE_STRIP_ERROR_STRINGS
    return vsnprintf(buffer, buf_size, format, vlist);
#endif
}