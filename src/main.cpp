#include "tensorflow/lite/core/c/common.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_log.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/micro_profiler.h"
#include "tensorflow/lite/micro/recording_micro_allocator.h"
#include "tensorflow/lite/micro/recording_micro_interpreter.h"
#include "models/hello_world_int8_model_data.h"
#include "tensorflow/lite/micro/system_setup.h"

#include "riotee.h"
#include "riotee_gpio.h"
#include "riotee_timing.h"
#include "riotee_adc.h"
#include "riotee_uart.h"
#include "printf.h"

#include "shtc3.h"
#include "vm1010.h"
// #include "testdata/yes_1000ms_audio_data.h"
#include "micro_speech.h"

#define PIN_MICROPHONE_DISABLE PIN_D5
#define MICROPHONE_SAMPLES 8000

void suspend_callback(void) {}

void startup_callback(void)
{
	riotee_gpio_cfg_output(PIN_MICROPHONE_DISABLE);
	riotee_gpio_set(PIN_MICROPHONE_DISABLE);
}

/* This gets called after every reset */
void reset_callback(void)
{
	riotee_gpio_cfg_output(PIN_LED_CTRL);
	/* Required for VM1010 */
	riotee_adc_init();

	vm1010_cfg_t cfg = {
		.pin_mode = PIN_D10,
		.pin_dout = PIN_D4,
		.pin_vout = PIN_D2,
		.pin_vbias = PIN_D3};
	vm1010_init(&cfg);
}

void turnoff_callback(void)
{
	riotee_gpio_clear(PIN_LED_CTRL);
	/* Disable the microphone */
	riotee_gpio_set(PIN_MICROPHONE_DISABLE);
	vm1010_exit();
}

int16_t samples[MICROPHONE_SAMPLES];
int main(void)
{
	riotee_uart_init(PIN_D1, RIOTEE_UART_BAUDRATE_115200);
	int rc;
	printf("Starting up\r\n");
	// TestAudioSample("yes", g_yes_1000ms_audio_data, g_yes_1000ms_audio_data_size);

	for (;;)
	{
		// printf("Starting up\r\n");
		// riotee_wait_cap_charged();

		/* Switch on microphone */
		riotee_gpio_clear(PIN_MICROPHONE_DISABLE);
		/* Wait for 2ms for V_BIAS to come up */
		riotee_sleep_ticks(70);

		/* Wait for wake-on-sound signal from microphone */
		if ((rc = vm1010_wait4sound()) != RIOTEE_SUCCESS)
		{
			printf("Error while waiting for sound: %d", rc);
			riotee_gpio_set(PIN_MICROPHONE_DISABLE);
			continue;
		}
		/* Wait until microphone can be sampled (see VM1010 datasheet)*/
		riotee_sleep_ticks(5);
		// printf("Sampling..");
		rc = vm1010_sample(samples, MICROPHONE_SAMPLES, 2);
		/* Disable the microphone */
		riotee_gpio_set(PIN_MICROPHONE_DISABLE);
		if (rc != RIOTEE_SUCCESS)
		{
			printf("Error during sampling: %d", rc);
		}
		riotee_sleep_ms(500);
		TestAudioSample("who knows", samples, MICROPHONE_SAMPLES);
		riotee_sleep_ms(500);
		// printf("UU");
		// // // Print samples to UART
		// for (int i = 0; i < MICROPHONE_SAMPLES; i++)
		// {
		// 	// if (samples[i] < -1600)
		// 	// {
		// 	// 	continue;
		// 	// }
		// 	riotee_putc((uint8_t)(0x00FF & samples[i]));
		// 	riotee_putc((uint8_t)(samples[i] >> 8));
		// }
	}
}
