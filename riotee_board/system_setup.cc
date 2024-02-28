#include "tensorflow/lite/micro/system_setup.h"
#include "riotee_timing.h"
#include <riotee_uart.h>

namespace tflite
{

    // Calling this method enables a timer that runs for eternity. The user is
    // responsible for avoiding trampling on this timer's config, otherwise timing
    // measurements may no longer be valid.
    void InitializeTarget()
    {
        riotee_timing_init();
        riotee_uart_init(PIN_D1, RIOTEE_UART_BAUDRATE_115200);
    }

} // namespace tflite