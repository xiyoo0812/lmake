#工程名字
PROJECT_NAME = {{%= PROJECT_NAME %}}

#目标名字
TARGET_NAME = {{%= TARGET_NAME %}}

#系统环境
UNAME_S = $(shell uname -s)

#伪目标
.PHONY: clean all target pre_build post_build
all : pre_build target post_build

#CFLAG
MYCFLAGS =

#需要定义的FLAG
{{% for _, flag in pairs(FLAGS or {}) do %}}
MYCFLAGS += -{{%= flag %}}
{{% end %}}

{{% if STDC then %}}
#c标准库版本
#gnu99/gnu11/gnu17
STDC = -std={{%= STDC %}}
{{% end %}}

{{% if STDCPP then %}}
#c++标准库版本
#c++11/c++14/c++17/c++20
STDCPP = -std={{%= STDCPP %}}
{{% end %}}

#需要的include目录
{{% for _, include in pairs(INCLUDES or {}) do %}}
MYCFLAGS += -I{{%= include %}}
{{% end %}}

#需要定义的选项
{{% for _, define in pairs(DEFINES or {}) do %}}
MYCFLAGS += -D{{%= define %}}
{{% end %}}
{{% if #LINUX_DEFINES > 0 then %}}
ifeq ($(UNAME_S), Linux)
{{% for _, define in pairs(LINUX_DEFINES or {}) do %}}
MYCFLAGS += -D{{%= define %}}
{{% end %}}
endif
{{% end %}}
{{% if #DARWIN_DEFINES > 0 then %}}
ifeq ($(UNAME_S), Darwin)
{{% for _, define in pairs(DARWIN_DEFINES or {}) do %}}
MYCFLAGS += -D{{%= define %}}
{{% end %}}
endif
{{% end %}}

#LDFLAGS
LDFLAGS =

#需要附件link库目录
{{% for _, lib_dir in pairs(LIBRARY_DIR or {}) do %}}
LDFLAGS += -L{{%= lib_dir %}}
{{% end %}}

#源文件路径
{{% if SRC_DIR then %}}
SRC_DIR = {{%= SRC_DIR %}}
{{% else %}}
SRC_DIR = ./src
{{% end %}}

#需要排除的源文件,目录基于$(SRC_DIR)
EXCLUDE =
{{% for _, exclude in pairs(EXCLUDE_FILE or {}) do %}}
EXCLUDE += $(SRC_DIR)/{{%= exclude %}}
{{% end %}}

#需要连接的库文件
LIBS =
{{% if MIMALLOC_DIR then %}}
#是否启用mimalloc库
LIBS += -lmimalloc -lpthread
MYCFLAGS += -I{{%= MIMALLOC_DIR %}} -include ../../mimalloc-ex.h
{{% end %}}
#系统库
LIBS += -lm -ldl -lstdc++
#自定义库
{{% for _, lib in pairs(LIBS) do %}}
LIBS += -l{{%= lib %}}
{{% end %}}
{{% if #LINUX_LIBS > 0 then %}}
ifeq ($(UNAME_S), Linux)
{{% for _, lib in pairs(LINUX_LIBS) do %}}
LIBS += -l{{%= lib %}}
{{% end %}}
endif
{{% end %}}
{{% if #DARWIN_LIBS > 0 then %}}
ifeq ($(UNAME_S), Darwin)
{{% for _, lib in pairs(DARWIN_LIBS) do %}}
LIBS += -l{{%= lib %}}
{{% end %}}
endif
{{% end %}}

#定义基础的编译选项
CC = gcc
CX = c++
CFLAGS = -g -O2 -Wall -Wno-deprecated -Wextra -Wno-unknown-pragmas $(STDC) $(MYCFLAGS)
CXXFLAGS = -g -O2 -Wall -Wno-deprecated -Wextra -Wno-unknown-pragmas $(STDCPP) $(MYCFLAGS)

#项目目录
ifndef SOLUTION_DIR
SOLUTION_DIR=./
endif

#临时文件目录
INT_DIR = $(SOLUTION_DIR)temp/$(PROJECT_NAME)

{{% if PROJECT_TYPE ~= "exe" then %}}
#目标文件前缀，定义则.so和.a加lib前缀，否则不加
{{% if LIB_PREFIX then %}}
PROJECT_PREFIX = lib
{{% else %}}
PROJECT_PREFIX =
{{% end %}}
{{% end %}}

#目标定义
{{% if PROJECT_TYPE == "static" then %}}
TARGET_DIR = $(SOLUTION_DIR)library
TARGET_STATIC =  $(TARGET_DIR)/$(PROJECT_PREFIX)$(TARGET_NAME).a
{{% elseif PROJECT_TYPE == "dynamic" then %}}
MYCFLAGS += -fPIC
TARGET_DIR = $(SOLUTION_DIR)bin
TARGET_DYNAMIC =  $(TARGET_DIR)/$(PROJECT_PREFIX)$(TARGET_NAME).so
#macos系统so链接问题
ifeq ($(UNAME_S), Darwin)
LDFLAGS += -install_name $(PROJECT_PREFIX)$(TARGET_NAME).so
endif
{{% else %}}
TARGET_DIR = $(SOLUTION_DIR)bin
TARGET_EXECUTE =  $(TARGET_DIR)/$(TARGET_NAME)
{{% end %}}

#link添加.so目录
LDFLAGS += -L$(TARGET_DIR)

#自动生成目标
OBJS =
{{% if next(OBJS) then %}}
{{% local OBJS = table.concat(OBJS, "") %}}
COBJS = $(patsubst %.c, $(INT_DIR)/%.o, {{%= OBJS %}})
MOBJS = $(patsubst %.m, $(INT_DIR)/%.o, $(COBJS))
CCOBJS = $(patsubst %.cc, $(INT_DIR)/%.o, $(MOBJS))
OBJS = $(patsubst %.cpp, $(INT_DIR)/%.o, $(CCOBJS))
{{% else %}}
{{% for _, sub_dir in pairs(SUB_DIR or {}) do %}}
#子目录
OBJS += $(patsubst $(SRC_DIR)/{{%= sub_dir%}}/%.cpp, $(INT_DIR)/{{%= sub_dir%}}/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/{{%= sub_dir%}}/*.cpp)))
OBJS += $(patsubst $(SRC_DIR)/{{%= sub_dir%}}/%.cc, $(INT_DIR)/{{%= sub_dir%}}/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/{{%= sub_dir%}}/*.c)))
OBJS += $(patsubst $(SRC_DIR)/{{%= sub_dir%}}/%.c, $(INT_DIR)/{{%= sub_dir%}}/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/{{%= sub_dir%}}/*.cc)))
OBJS += $(patsubst $(SRC_DIR)/{{%= sub_dir%}}/%.m, $(INT_DIR)/{{%= sub_dir%}}/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/{{%= sub_dir%}}/*.m)))
{{% end %}}
#根目录
OBJS += $(patsubst $(SRC_DIR)/%.cpp, $(INT_DIR)/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/*.cpp)))
OBJS += $(patsubst $(SRC_DIR)/%.c, $(INT_DIR)/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/*.c)))
OBJS += $(patsubst $(SRC_DIR)/%.cc, $(INT_DIR)/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/*.cc)))
OBJS += $(patsubst $(SRC_DIR)/%.m, $(INT_DIR)/%.o, $(filter-out $(EXCLUDE), $(wildcard $(SRC_DIR)/*.m)))
{{% end %}}

{{% if PROJECT_TYPE == "static" then %}}
$(TARGET_STATIC) : $(OBJS)
	ar rcs $@ $(OBJS)
	ranlib $@
{{% end %}}

{{% if PROJECT_TYPE == "dynamic" then %}}
$(TARGET_DYNAMIC) : $(OBJS)
	$(CC) -o $@ -shared $(OBJS) $(LDFLAGS) $(LIBS)
{{% end %}}

{{% if PROJECT_TYPE == "exe" then %}}
$(TARGET_EXECUTE) : $(OBJS)
	$(CC) -o $@  $(OBJS) $(LDFLAGS) $(LIBS)
{{% end %}}

# 编译所有源文件
$(INT_DIR)/%.o : $(SRC_DIR)/%.cpp
	$(CX) $(CXXFLAGS) -c $< -o $@
$(INT_DIR)/%.o : $(SRC_DIR)/%.cc
	$(CX) $(CXXFLAGS) -c $< -o $@
$(INT_DIR)/%.o : $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@
$(INT_DIR)/%.o : $(SRC_DIR)/%.m
	$(CC) $(CFLAGS) -c $< -o $@

#target伪目标
{{% if PROJECT_TYPE == "static" then %}}
target : $(TARGET_STATIC)
{{% elseif PROJECT_TYPE == "dynamic" then %}}
target : $(TARGET_DYNAMIC)
{{% else %}}
target : $(TARGET_EXECUTE)
{{% end %}}

#clean伪目标
clean :
	rm -rf $(INT_DIR)

#预编译
pre_build:
	mkdir -p $(INT_DIR)
	mkdir -p $(TARGET_DIR)
{{% for _, sub_dir in pairs(SUB_DIR or {}) do %}}
	mkdir -p $(INT_DIR)/{{%= sub_dir %}}
{{% end %}}

#后编译
post_build:
