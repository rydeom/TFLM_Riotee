
#include "riotee.h"
#include "riotee_gpio.h"
#include "riotee_timing.h"
#include "riotee_uart.h"
#include "tensorflow/lite/core/c/common.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_log.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/micro_profiler.h"
#include "tensorflow/lite/micro/recording_micro_allocator.h"
#include "tensorflow/lite/micro/recording_micro_interpreter.h"
#include "models/hello_world_int8_model_data.h"
#include "tensorflow/lite/micro/system_setup.h"
#include "printf.h"

namespace
{
	using HelloWorldOpResolver = tflite::MicroMutableOpResolver<1>;

	TfLiteStatus RegisterOps(HelloWorldOpResolver &op_resolver)
	{
		TF_LITE_ENSURE_STATUS(op_resolver.AddFullyConnected());
		return kTfLiteOk;
	}
}

TfLiteStatus LoadQuantModelAndPerformInference()
{
	// Map the model into a usable data structure. This doesn't involve any
	// copying or parsing, it's a very lightweight operation.
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

	float output_scale = output->params.scale;
	int output_zero_point = output->params.zero_point;

	// Check if the predicted output is within a small range of the
	// expected output
	float epsilon = 0.05;

	constexpr int kNumTestValues = 4;
	float golden_inputs_float[kNumTestValues] = {0.77, 1.57, 2.3, 3.14};

	// The int8 values are calculated using the following formula
	// (golden_inputs_float[i] / input->params.scale + input->params.scale)
	int8_t golden_inputs_int8[kNumTestValues] = {-96, -63, -34, 0};

	for (int i = 0; i < kNumTestValues; ++i)
	{
		input->data.int8[0] = golden_inputs_int8[i];
		TF_LITE_ENSURE_STATUS(interpreter.Invoke());
		int lool = output->data.int8[0] - output_zero_point;
		float y_pred = lool * output_scale;
		printf("Test case %d\r\n", lool);
		printf("Input value: %f\r\n", golden_inputs_float[i]);
		printf("Output vlaue: %d\r\n", output->data.int8[0]);
		printf("Real value: %f\r\n", sin(golden_inputs_float[i]));
		printf("Predicted value: %f\r\n", y_pred);
		TFLITE_CHECK_LE(abs(sin(golden_inputs_float[i]) - y_pred), epsilon);
	}

	return kTfLiteOk;
}

void suspend_callback(void)
{
}

int main(void)
{
	riotee_uart_init(PIN_D1, RIOTEE_UART_BAUDRATE_115200);
	tflite::InitializeTarget();
	TF_LITE_ENSURE_STATUS(LoadQuantModelAndPerformInference());
	printf("~~~ALL TESTS PASSED~~~\r\n");

	for (;;)
	{
	}
}
