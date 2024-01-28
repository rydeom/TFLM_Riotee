#include "tensorflow/lite/micro/micro_time.h"
#include "riotee_timing.h"

namespace tflite
{
    uint32_t ticks_per_second() { return 32768; }

    uint32_t GetCurrentTimeTicks()
    {
        uint64_t ticks = 0;
        riotee_rc_t rc = riotee_timing_now(&ticks);

        if (rc != RIOTEE_SUCCESS)
        {
            return 0;
        }

        return ticks;
    }

}