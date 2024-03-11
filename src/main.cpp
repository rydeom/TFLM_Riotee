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

#define PIN_MICROPHONE_DISABLE PIN_D5

namespace
{
	using HelloWorldOpResolver = tflite::MicroMutableOpResolver<1>;

	TfLiteStatus RegisterOps(HelloWorldOpResolver &op_resolver)
	{
		TF_LITE_ENSURE_STATUS(op_resolver.AddFullyConnected());
		return kTfLiteOk;
	}
}

void suspend_callback(void) {}

TfLiteStatus run_model(float inputf)
{
	const tflite::Model *model =
		::tflite::GetModel(g_hello_world_int8_model_data);
	TFLITE_CHECK_EQ(model->version(), TFLITE_SCHEMA_VERSION);

	HelloWorldOpResolver op_resolver;
	TF_LITE_ENSURE_STATUS(RegisterOps(op_resolver));

	// Arena size just a round number. The exact arena usage can be determined
	// using the RecordingMicroInterpreter.
	constexpr int kTensorArenaSize = 3000;
	uint8_t tensor_arena[kTensorArenaSize];

	tflite::MicroInterpreter interpreter(model, op_resolver, tensor_arena,
										 kTensorArenaSize);

	TF_LITE_ENSURE_STATUS(interpreter.AllocateTensors());

	TfLiteTensor *input = interpreter.input(0);
	TFLITE_CHECK_NE(input, nullptr);

	TfLiteTensor *output = interpreter.output(0);
	TFLITE_CHECK_NE(output, nullptr);

	// float output_scale = output->params.scale;
	// int output_zero_point = output->params.zero_point;

	int input_int8 = inputf / input->params.scale + input->params.zero_point;

	input->data.int8[0] = input_int8;
	TF_LITE_ENSURE_STATUS(interpreter.Invoke());

	// float y_pred = (output->data.int8[0] - output_zero_point) * output_scale;
	// printf("Predicted value: %f\r\n", y_pred);
	// printf("Golden value: %f\r\n", sin(inputf));

	return kTfLiteOk;
}

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

int16_t samples[8192];
int main(void)
{
	riotee_uart_init(PIN_D1, RIOTEE_UART_BAUDRATE_115200);
	// tflite::InitializeTarget();
	// uint64_t startTicks = 0;
	// uint64_t endTicks = 0;
	// riotee_timing_now(&startTicks);
	// run_model(0.77f);
	// riotee_timing_now(&endTicks);
	// printf("Ticks: %llu\r\n", endTicks - startTicks);
	int rc;

	for (;;)
	{
		// printf("Starting up\r\n");
		// riotee_wait_cap_charged();

		/* Switch on microphone */
		riotee_gpio_clear(PIN_MICROPHONE_DISABLE);
		/* Wait for 2ms for V_BIAS to come up */
		riotee_sleep_ticks(70);

		/* Wait for wake-on-sound signal from microphone */
		// if ((rc = vm1010_wait4sound()) != RIOTEE_SUCCESS)
		// {
		// 	printf("Error while waiting for sound: %d", rc);
		// 	riotee_gpio_set(PIN_MICROPHONE_DISABLE);
		// 	continue;
		// }
		/* Wait until microphone can be sampled (see VM1010 datasheet)*/
		riotee_sleep_ticks(5);
		// printf("Sampling..");
		rc = vm1010_sample(samples, 8192, 2);
		/* Disable the microphone */
		// riotee_gpio_set(PIN_MICROPHONE_DISABLE);
		if (rc != RIOTEE_SUCCESS)
		{
			printf("Error during sampling: %d", rc);
		}
		printf("UU");
		// Print samples to UART
		for (int i = 0; i < 8192; i++)
		{
			// if (samples[i] < -1600)
			// {
			// 	continue;
			// }
			riotee_putc((uint8_t)(0x00FF & samples[i]));
			riotee_putc((uint8_t)(samples[i] >> 8));
			// printf("%d\r\n", samples[i]);
		}
	}
}
