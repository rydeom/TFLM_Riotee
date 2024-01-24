RIOTEE_SDK_ROOT ?= /Users/janstiefel/code/Riotee_SDK
GNU_INSTALL_ROOT ?= /Applications/ArmGNUToolchain/13.2.Rel1/arm-none-eabi/bin/
#TENSORFLOW_ROOT ?= /Users/janstiefel/code/tflite-micro
TENSORFLOW_ROOT ?= /Users/janstiefel/code/Riotee_AppTemplate/tensorflow

CORE_DIR := $(RIOTEE_SDK_ROOT)/core
DRIVER_DIR := $(RIOTEE_SDK_ROOT)/drivers
RTOS_DIR := $(RIOTEE_SDK_ROOT)/external/freertos
NRFX_DIR := $(RIOTEE_SDK_ROOT)/external/nrfx
CMSIS_DIR := $(RIOTEE_SDK_ROOT)/external/CMSIS_5
LINKER_SCRIPT:= $(RIOTEE_SDK_ROOT)/linker.ld
NRF_DEV_NUM := 52833

RIOTEE_STACK_SIZE ?= 2048
RIOTEE_RAM_RETAINED_SIZE ?= 8192

PRJ_ROOT := /Users/janstiefel/code/Riotee_AppTemplate
OUTPUT_DIR := _build

CC := $(GNU_INSTALL_ROOT)arm-none-eabi-gcc
CXX := $(GNU_INSTALL_ROOT)arm-none-eabi-g++

SRC_FILES = \
	$(PRJ_ROOT)/src/main.cc \
	$(PRJ_ROOT)/src/led.cc \
	$(PRJ_ROOT)/src/models/hello_world_float_model_data.cc \
	$(PRJ_ROOT)/src/models/hello_world_int8_model_data.cc \

INC_DIRS = \
	$(PRJ_ROOT)/src \
	$(PRJ_ROOT)/include \
	$(TENSORFLOW_ROOT) \
	$(TENSORFLOW_ROOT)/tensorflow/lite \
	$(TENSORFLOW_ROOT)/tensorflow/lite/c \
	$(TENSORFLOW_ROOT)/tensorflow/lite/core \
	$(TENSORFLOW_ROOT)/tensorflow/lite/core/api \
	$(TENSORFLOW_ROOT)/tensorflow/lite/core/c \
	$(TENSORFLOW_ROOT)/tensorflow/lite/kernels \
	$(TENSORFLOW_ROOT)/tensorflow/lite/kernels/internal \
	$(TENSORFLOW_ROOT)/tensorflow/lite/kernels/internal/optimized \
	$(TENSORFLOW_ROOT)/tensorflow/lite/kernels/internal/reference \
	$(TENSORFLOW_ROOT)/tensorflow/lite/kernels/internal/reference/integer_ops \
	$(TENSORFLOW_ROOT)/tensorflow/lite/schema \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro \
	$(TENSORFLOW_ROOT)/third_party/flatbuffers/include \
	$(TENSORFLOW_ROOT)/third_party/gemmlowp \
	$(TENSORFLOW_ROOT)/third_party/ruy \
	$(TENSORFLOW_ROOT)/third_party/kissfft 

MICROLITE_TEST_SRCS := \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/fake_micro_context_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/flatbuffer_utils_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_arena_threshold_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_helpers_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_allocation_info_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_interpreter_context_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_log_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_interpreter_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_mutable_op_resolver_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_resource_variable_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_time_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_utils_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/recording_micro_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/non_persistent_arena_buffer_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/persistent_arena_buffer_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/recording_single_arena_buffer_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/single_arena_buffer_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/testing_helpers_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_planner/greedy_memory_planner_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_planner/linear_memory_planner_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_planner/non_persistent_buffer_planner_shim_test.cc

MICROLITE_CC_KERNEL_SRCS := \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/activations.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/activations_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/add.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/add_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/add_n.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/arg_min_max.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/assign_variable.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/batch_matmul.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/batch_to_space_nd.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/broadcast_args.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/broadcast_to.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/call_once.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/cast.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/ceil.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/circular_buffer.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/circular_buffer_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/comparisons.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/concatenation.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/conv.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/conv_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/cumsum.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/depth_to_space.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/depthwise_conv.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/depthwise_conv_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/dequantize.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/dequantize_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/detection_postprocess.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/div.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/elementwise.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/elu.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/embedding_lookup.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/ethosu.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/exp.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/expand_dims.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/fill.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/floor.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/floor_div.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/floor_mod.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/fully_connected.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/fully_connected_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/gather.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/gather_nd.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/hard_swish.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/hard_swish_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/if.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/kernel_runner.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/kernel_util.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/l2norm.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/l2_pool_2d.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/leaky_relu.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/leaky_relu_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/logical.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/logical_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/logistic.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/logistic_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/log_softmax.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/lstm_eval.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/lstm_eval_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/maximum_minimum.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/micro_tensor_utils.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/mirror_pad.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/mul.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/mul_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/neg.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/pack.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/pad.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/pooling.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/pooling_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/prelu.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/prelu_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/quantize.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/quantize_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/read_variable.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/reduce.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/reduce_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/reshape.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/reshape_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/resize_bilinear.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/resize_nearest_neighbor.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/round.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/select.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/shape.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/slice.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/softmax.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/softmax_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/space_to_batch_nd.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/space_to_depth.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/split.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/split_v.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/squared_difference.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/squeeze.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/strided_slice.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/strided_slice_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/sub.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/sub_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/svdf.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/svdf_common.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/tanh.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/transpose.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/transpose_conv.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/unidirectional_sequence_lstm.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/unpack.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/var_handle.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/while.cc \
	$(TENSORFLOW_ROOT)/tensorflow/lite/micro/kernels/zeros_like.cc

MICROLITE_CC_SIGNAL_KERNEL_SRCS := \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/delay.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/energy.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/fft_auto_scale_kernel.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/fft_auto_scale_common.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/filter_bank.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/filter_bank_log.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/filter_bank_square_root.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/filter_bank_square_root_common.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/filter_bank_spectral_subtraction.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/framer.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/irfft.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/rfft.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/stacker.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/overlap_add.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/pcan.cc \
	$(TENSORFLOW_ROOT)/signal/micro/kernels/window.cc \
	$(TENSORFLOW_ROOT)/signal/src/circular_buffer.cc \
	$(TENSORFLOW_ROOT)/signal/src/energy.cc \
	$(TENSORFLOW_ROOT)/signal/src/fft_auto_scale.cc \
	$(TENSORFLOW_ROOT)/signal/src/filter_bank.cc \
	$(TENSORFLOW_ROOT)/signal/src/filter_bank_log.cc \
	$(TENSORFLOW_ROOT)/signal/src/filter_bank_square_root.cc \
	$(TENSORFLOW_ROOT)/signal/src/filter_bank_spectral_subtraction.cc \
	$(TENSORFLOW_ROOT)/signal/src/irfft_float.cc \
	$(TENSORFLOW_ROOT)/signal/src/irfft_int16.cc \
	$(TENSORFLOW_ROOT)/signal/src/irfft_int32.cc \
	$(TENSORFLOW_ROOT)/signal/src/log.cc \
	$(TENSORFLOW_ROOT)/signal/src/max_abs.cc \
	$(TENSORFLOW_ROOT)/signal/src/msb_32.cc \
	$(TENSORFLOW_ROOT)/signal/src/msb_64.cc \
	$(TENSORFLOW_ROOT)/signal/src/overlap_add.cc \
	$(TENSORFLOW_ROOT)/signal/src/pcan_argc_fixed.cc \
	$(TENSORFLOW_ROOT)/signal/src/rfft_float.cc \
	$(TENSORFLOW_ROOT)/signal/src/rfft_int16.cc \
	$(TENSORFLOW_ROOT)/signal/src/rfft_int32.cc \
	$(TENSORFLOW_ROOT)/signal/src/square_root_32.cc \
	$(TENSORFLOW_ROOT)/signal/src/square_root_64.cc \
	$(TENSORFLOW_ROOT)/signal/src/window.cc

TFL_CC_SRCS := \
$(shell find $(TENSORFLOW_ROOT)/tensorflow/lite -type d \( -path $(TENSORFLOW_ROOT)/tensorflow/lite/experimental -o -path $(TENSORFLOW_ROOT)/tensorflow/lite/micro \) -prune -false -o -name "*.cc" -o -name "*.c")

MICROLITE_CC_BASE_SRCS := \
$(wildcard $(TENSORFLOW_ROOT)/tensorflow/lite/micro/*.cc) \
$(wildcard $(TENSORFLOW_ROOT)/tensorflow/lite/micro/riotee_board/*.cc) \
$(wildcard $(TENSORFLOW_ROOT)/tensorflow/lite/micro/arena_allocator/*.cc) \
$(wildcard $(TENSORFLOW_ROOT)/tensorflow/lite/micro/memory_planner/*.cc) \
$(wildcard $(TENSORFLOW_ROOT)/tensorflow/lite/micro/tflite_bridge/*.cc) \
$(TFL_CC_SRCS)

MICROLITE_CC_SRCS := $(filter-out $(MICROLITE_TEST_SRCS), $(MICROLITE_CC_BASE_SRCS))

SDK_SRC_FILES += \
	$(CORE_DIR)/startup.c \
	$(CORE_DIR)/thresholds.c \
	$(CORE_DIR)/printf.c \
	$(CORE_DIR)/radio.c \
	$(CORE_DIR)/ble.c \
	$(CORE_DIR)/i2c.c \
	$(CORE_DIR)/max20361.c \
	$(CORE_DIR)/am1805.c \
	$(CORE_DIR)/timing.c \
	$(CORE_DIR)/gpio.c \
	$(CORE_DIR)/uart.c \
	$(CORE_DIR)/spic.c \
	$(CORE_DIR)/runtime.c \
	$(CORE_DIR)/nvm.c \
	$(CORE_DIR)/adc.c \
	$(CORE_DIR)/stella.c \
	$(DRIVER_DIR)/shtc3.c \
	$(DRIVER_DIR)/vm1010.c \
	$(RTOS_DIR)/queue.c \
	$(RTOS_DIR)/list.c \
	$(RTOS_DIR)/tasks.c \
	$(RTOS_DIR)/event_groups.c \
	$(RTOS_DIR)/portable/GCC/ARM_CM4F/port.c

INC_DIRS += \
	$(CORE_DIR) \
	$(CORE_DIR)/include \
	$(DRIVER_DIR)/include \
	$(RTOS_DIR)/include \
	$(RTOS_DIR)/portable/GCC/ARM_CM4F \
	$(NRFX_DIR) \
	$(NRFX_DIR)/hal \
	$(NRFX_DIR)/mdk \
	$(NRFX_DIR)/templates \
	$(CMSIS_DIR)/CMSIS/Core/Include


OBJS = $(subst $(PRJ_ROOT)/,$(OUTPUT_DIR)/, $(addsuffix .o, $(SRC_FILES)))
OBJS += $(subst $(RIOTEE_SDK_ROOT)/,$(OUTPUT_DIR)/, $(addsuffix .o, $(SDK_SRC_FILES)))
OBJS += $(subst $(TENSORFLOW_ROOT)/,$(OUTPUT_DIR)/, $(addsuffix .o, $(MICROLITE_CC_SRCS)))
OBJS += $(subst $(TENSORFLOW_ROOT)/,$(OUTPUT_DIR)/, $(addsuffix .o, $(MICROLITE_CC_KERNEL_SRCS)))
OBJS += $(subst $(TENSORFLOW_ROOT)/,$(OUTPUT_DIR)/, $(addsuffix .o, $(MICROLITE_CC_SIGNAL_KERNEL_SRCS)))

#$(info $(OBJS))

INCLUDES = $(INC_DIRS:%=-I%)

OPT = -O3 -g3

CFLAGS = ${INCLUDES}
CFLAGS += $(OPT)
CFLAGS += -DNRF${NRF_DEV_NUM}_XXAA
CFLAGS += -DRIOTEE_STACK_SIZE=${RIOTEE_STACK_SIZE}
CFLAGS += -DARM_MATH_CM4
CFLAGS += -DFLOAT_ABI_HARD
CFLAGS += -Wall
CFLAGS += -fno-builtin
CFLAGS += -mthumb
CFLAGS += -mcpu=cortex-m4
CFLAGS += -mabi=aapcs
CFLAGS += -mfloat-abi=hard
CFLAGS += -mfpu=fpv4-sp-d16
CFLAGS += -fsingle-precision-constant
CFLAGS += -ffunction-sections
CFLAGS += -fdata-sections

CPPFLAGS = ${CFLAGS} -fno-exceptions
CPPFLAGS += -std=c++17
CPPFLAGS += -fno-rtti 
CPPFLAGS += -fno-threadsafe-statics 
CPPFLAGS += -Wnon-virtual-dtor 
CPPFLAGS += -Werror
CPPFLAGS += -fno-unwind-tables
CPPFLAGS += -ffunction-sections
CPPFLAGS += -fdata-sections
CPPFLAGS += -fmessage-length=0
CPPFLAGS += -DTF_LITE_STATIC_MEMORY 


ASMFLAGS += -g3
ASMFLAGS += -mcpu=cortex-m4
ASMFLAGS += -mthumb -mabi=aapcs
ASMFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
ASMFLAGS += -DFLOAT_ABI_HARD
ASMFLAGS += -DNRF${NRF_DEV_NUM}_XXAA

ARFLAGS = -rcs

LDFLAGS += $(OPT)
LDFLAGS += -T$(LINKER_SCRIPT)
LDFLAGS += -mthumb -mabi=aapcs
LDFLAGS += -mcpu=cortex-m4
LDFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
LDFLAGS += $(LIBS)
# let linker dump unused sections
LDFLAGS += -Wl,--gc-sections,-Map=${OUTPUT_DIR}/build.map
# use newlib in nano version and system call stubs
LDFLAGS += --specs=nosys.specs
LDFLAGS += --specs=nano.specs
LDFLAGS += --specs=rdimon.specs
LDFLAGS += -Wl,--defsym=RIOTEE_RAM_RETAINED_SIZE=${RIOTEE_RAM_RETAINED_SIZE}
LDFLAGS += -L.

LIB_FILES += -lm
LIB_FILES += -lrdimon

TARGET = build

.PHONY: all clean

all: $(OUTPUT_DIR)/$(TARGET).hex

test: $(OUTPUT_DIR)/core/adc.c.o

compile_riotee_sdk:
	echo "Compiling Riotee SDK"


clean:
	rm -rf $(OUTPUT_DIR)

${OUTPUT_DIR}/%.c.o: ${RIOTEE_SDK_ROOT}/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
	@echo "CC $<"

${OUTPUT_DIR}/%.cc.o: ${PRJ_ROOT}/%.cc
	@mkdir -p $(@D)
	$(CXX) $(CPPFLAGS) -c $< -o $@
	@echo "CXX $<"

${OUTPUT_DIR}/%.cc.o: ${TENSORFLOW_ROOT}/%.cc
	@mkdir -p $(@D)
	$(CXX) $(CPPFLAGS) -c $< -o $@
	@echo "CXX $<"

${OUTPUT_DIR}/build.elf: $(OBJS)
	@mkdir -p $(@D)
	$(CXX) $(LDFLAGS) $(OBJS) -o $@ $(LIB_FILES)
	@echo "LINK $@"
	$(GNU_INSTALL_ROOT)arm-none-eabi-size $@

${OUTPUT_DIR}/build.hex: ${OUTPUT_DIR}/build.elf
	@mkdir -p $(@D)
	$(GNU_INSTALL_ROOT)arm-none-eabi-objcopy -O ihex $< $@
	@echo "HEX $@"

# Flash the program
flash: ${OUTPUT_DIR}/build.hex
	@echo Flashing: $<
	riotee-probe program -d nrf52 -f $<