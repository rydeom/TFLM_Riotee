RIOTEE_SDK_ROOT ?= /Users/janstiefel/code/fork/Riotee_SDK
GNU_INSTALL_ROOT ?= /Applications/ArmGNUToolchain/13.2.Rel1/arm-none-eabi/bin/

PRJ_ROOT := .
OUTPUT_DIR := _build

# Size of the user stack in bytes. Must be multiple of 4.
RIOTEE_STACK_SIZE:= 1024
# Size of retained memory in bytes including STACK_SIZE.
RIOTEE_RAM_RETAINED_SIZE:= 8192


ifndef RIOTEE_SDK_ROOT
  $(error RIOTEE_SDK_ROOT is not set)
endif

SRC_FILES = \
  $(PRJ_ROOT)/src/main.cc \
  $(PRJ_ROOT)/src/models/hello_world_int8_model_data.cc

INC_DIRS = \
  $(PRJ_ROOT)/include \
  $(PRJ_ROOT)/src \
  $(PRJ_ROOT)/tensorflow \
  $(PRJ_ROOT)/tensorflow/third_party/flatbuffers/include \
  $(PRJ_ROOT)/tensorflow/third_party/gemmlowp \
  $(PRJ_ROOT)/tensorflow/third_party/ruy 

LIB_DIRS = \
  $(PRJ_ROOT)
LIB_FILES += -ltensorflow-microlite

include $(RIOTEE_SDK_ROOT)/Makefile
