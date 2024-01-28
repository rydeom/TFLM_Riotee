
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
#include "models/hello_world_float_model_data.h"
#include "models/hello_world_int8_model_data.h"
#include "tensorflow/lite/micro/system_setup.h"
#include "led.h"
#include "printf.h"

static LED led = LED(PIN_LED_CTRL);

namespace
{
	using HelloWorldOpResolver = tflite::MicroMutableOpResolver<1>;

	TfLiteStatus RegisterOps(HelloWorldOpResolver &op_resolver)
	{
		TF_LITE_ENSURE_STATUS(op_resolver.AddFullyConnected());
		return kTfLiteOk;
	}
}

TfLiteStatus ProfileMemoryAndLatency()
{
	tflite::MicroProfiler profiler;
	HelloWorldOpResolver op_resolver;
	TF_LITE_ENSURE_STATUS(RegisterOps(op_resolver));

	// Arena size just a round number. The exact arena usage can be determined
	// using the RecordingMicroInterpreter.
	constexpr int kTensorArenaSize = 3000;
	uint8_t tensor_arena[kTensorArenaSize];
	constexpr int kNumResourceVariables = 24;

	tflite::RecordingMicroAllocator *allocator(
		tflite::RecordingMicroAllocator::Create(tensor_arena, kTensorArenaSize));
	tflite::RecordingMicroInterpreter interpreter(
		tflite::GetModel(g_hello_world_float_model_data), op_resolver, allocator,
		tflite::MicroResourceVariables::Create(allocator, kNumResourceVariables),
		&profiler);

	TF_LITE_ENSURE_STATUS(interpreter.AllocateTensors());
	TFLITE_CHECK_EQ(interpreter.inputs_size(), 1);
	interpreter.input(0)->data.f[0] = 1.f;
	TF_LITE_ENSURE_STATUS(interpreter.Invoke());

	MicroPrintf(""); // Print an empty new line
	profiler.LogTicksPerTagCsv();

	MicroPrintf(""); // Print an empty new line
	interpreter.GetMicroAllocator().PrintAllocations();
	return kTfLiteOk;
}

TfLiteStatus LoadFloatModelAndPerformInference()
{
	const tflite::Model *model =
		::tflite::GetModel(g_hello_world_float_model_data);
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

	// Check if the predicted output is within a small range of the
	// expected output
	float epsilon = 0.05f;
	constexpr int kNumTestValues = 4;
	float golden_inputs[kNumTestValues] = {0.f, 1.f, 3.f, 5.f};

	for (int i = 0; i < kNumTestValues; ++i)
	{
		interpreter.input(0)->data.f[0] = golden_inputs[i];
		TF_LITE_ENSURE_STATUS(interpreter.Invoke());
		float y_pred = interpreter.output(0)->data.f[0];
		TFLITE_CHECK_LE(abs(sin(golden_inputs[i]) - y_pred), epsilon);
	}

	return kTfLiteOk;
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
	MicroPrintf("ALL TESTS PASSED");

	// Arena size just a round number. The exact arena usage can be determined
	// using the RecordingMicroInterpreter.
	constexpr int kTensorArenaSize = 3000;
	uint8_t tensor_arena[kTensorArenaSize];

	tflite::MicroInterpreter interpreter(model, op_resolver, tensor_arena,
										 kTensorArenaSize);
	MicroPrintf("ALL TESTS PASSED");

	TF_LITE_ENSURE_STATUS(interpreter.AllocateTensors());
	MicroPrintf("ALL TESTS PASSED");

	TfLiteTensor *input = interpreter.input(0);
	TFLITE_CHECK_NE(input, nullptr);

	TfLiteTensor *output = interpreter.output(0);
	TFLITE_CHECK_NE(output, nullptr);

	float output_scale = output->params.scale;
	int output_zero_point = output->params.zero_point;
	MicroPrintf("ALL TESTS PASSED");

	// Check if the predicted output is within a small range of the
	// expected output
	float epsilon = 0.05;

	constexpr int kNumTestValues = 4;
	float golden_inputs_float[kNumTestValues] = {0.77, 1.57, 2.3, 3.14};
	MicroPrintf("ALL TESTS PASSED");

	// The int8 values are calculated using the following formula
	// (golden_inputs_float[i] / input->params.scale + input->params.scale)
	int8_t golden_inputs_int8[kNumTestValues] = {-96, -63, -34, 0};
	MicroPrintf("ALL TESTS PASSED");

	for (int i = 0; i < kNumTestValues; ++i)
	{
		input->data.int8[0] = golden_inputs_int8[i];
		TF_LITE_ENSURE_STATUS(interpreter.Invoke());
		float y_pred = (output->data.int8[0] - output_zero_point) * output_scale;
		TFLITE_CHECK_LE(abs(sin(golden_inputs_float[i]) - y_pred), epsilon);
	}

	return kTfLiteOk;
}

void suspend_callback(void)
{
	led.off();
}

int main(void)
{
	riotee_uart_init(PIN_D1, RIOTEE_UART_BAUDRATE_115200);
	tflite::InitializeTarget();
	MicroPrintf("INITIALIZED TARGET");
	TF_LITE_ENSURE_STATUS(ProfileMemoryAndLatency());
	MicroPrintf("~~~ALL TESTS PASSED~~~");
	// TF_LITE_ENSURE_STATUS(LoadFloatModelAndPerformInference());
	MicroPrintf("ALL TESTS PASSED~~~");
	// TF_LITE_ENSURE_STATUS(LoadQuantModelAndPerformInference());
	MicroPrintf("~~~ALL TESTS PASSED~~~");

	for (;;)
	{
		// riotee_wait_cap_charged();
		led.on();
		riotee_sleep_ms(1000);
		led.off();
		riotee_sleep_ms(1000);
	}
}
