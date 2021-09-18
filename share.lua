--share.lmak

--标准库版本
--gnu99/gnu11/gnu17
STDC = "gnu99"

--c++11/c++14/c++17/c++20
STDCPP = "c++14"

--需要的FLAGS
FLAGS = {
}

--需要的include目录
INCLUDES = {
}

--LINUX需要的include目录
LINUX_INCLUDES = {
}

--DARWIN需要的include目录
DARWIN_INCLUDES = {
}

--WINDOWS需要include目录
WINDOWS_INCLUDES = {
}

--目标文件前缀
--LIB_PREFIX = 1

--需要定义的选项
DEFINES = {
}

--LINUX需要定义的选项
LINUX_DEFINES = {
}

--DARWIN需要定义的选项
DARWIN_DEFINES = {
}

--WINDOWS需要定义的选项
WINDOWS_DEFINES = {
}

--需要附加link库目录
LIBRARY_DIR = {
}

--WINDOWS需要附加link库目录
WINDOWS_LIBRARY_DIR = {
}

--LINUX需要附加link库目录
LINUX_LIBRARY_DIR = {
}

--DARWIN需要附加link库目录
DARWIN_LIBRARY_DIR = {
}

--源文件路径
SRC_DIR = "src"

--子目录路径
SUB_DIR = {
}

--需要排除的源文件,目录基于$(SRC_DIR)
EXCLUDE_FILE = {
}

--是否启用mimalloc库
MIMALLOC_DIR = "../../mimalloc/mimalloc/include"

--需要连接的库文件
LIBS = {
}

--WINDOWS需要连接的库文件
--windows下没有-l自动连接的功能，库文件需要带前后缀
WINDOWS_LIBS = {
}

--LINUX需要连接的库文件
LINUX_LIBS = {
}

--DARWIN需要连接的库文件
DARWIN_LIBS = {
}

--WINDOWS预编译的库文件，需要copy到bin目录
--建议使用[[]]来包含字符串，否则有\转义问题
WINDOWS_PREBUILDS = {
}

--目标文件，可以在这里定义，如果没有定义，share.mak会自动生成
OBJS = {
}

--依赖项目
DEPS = {
}

--分组定义
GROUP = "proj"
