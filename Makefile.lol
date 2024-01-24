RIOTEE_SDK_ROOT ?= /Users/janstiefel/code/Riotee_SDK
GNU_INSTALL_ROOT ?= /Applications/ArmGNUToolchain/13.2.Rel1/arm-none-eabi/bin/
TFLM ?= /Users/janstiefel/code/tflite-micro

PRJ_ROOT := .
OUTPUT_DIR := _build
TENSORFLOW_LIB ?= $(PRJ_ROOT)/lib

# Size of the user stack in bytes. Must be multiple of 4.
RIOTEE_STACK_SIZE:= 1024
# Size of retained memory in bytes including STACK_SIZE.
RIOTEE_RAM_RETAINED_SIZE:= 8192

LIB_DIRS += ${TENSORFLOW_LIB}

TFLITE_LIB = $(TENSORFLOW_LIB)/libtensorflow-microlite.a


ifndef RIOTEE_SDK_ROOT
  $(error RIOTEE_SDK_ROOT is not set)
endif

SRC_FILES = \
  $(PRJ_ROOT)/src/main.cc \
  $(PRJ_ROOT)/src/models/hello_world_float_model_data.cc \
  $(PRJ_ROOT)/src/models/hello_world_int8_model_data.cc 

INC_DIRS = \
  $(PRJ_ROOT)/src \
  $(TFLM) \
  $(TFLM)/tensorflow/lite/micro/tools/make/downloads \
  $(TFLM)/tensorflow/lite/micro/tools/make/downloads/flatbuffers/include \
  $(TFLM)/tensorflow/lite/micro/tools/make/downloads/gemmlowp \
  $(TFLM)/tensorflow/lite/micro/tools/make/downloads/kissfft \
  $(TFLM)/tensorflow/lite/micro/tools/make/downloads/ruy \
  $(PRJ_ROOT)/include 


include $(RIOTEE_SDK_ROOT)/Makefile
