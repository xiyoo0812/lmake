--share.lmak

--标准库版本
---std=gnu99/-std=c++11/-std=c++14
STDC = "-std=gnu99"

--需要的FLAGS
FLAGS = {
}

--需要的include目录
INCLUDES = {
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

--WIN32需要定义的选项
WIN32_DEFINES = {
}

--需要附件link库目录
LIBRARY_DIR = {
}

--源文件路径
SRC_DIR = "./src"

--子目录路径
SUB_DIR = {
}

--需要排除的源文件,目录基于$(SRC_DIR)
EXCLUDE_FILE={
}

--是否启用mimalloc库
--MIMALLOC_DIR = "../../extend"

--需要连接的库文件
LIBS = {
}

--WIN32需要连接的库文件
WIN32_LIBS = {
}

--LINUX需要连接的库文件
LINUX_LIBS = {
}

--DARWIN需要连接的库文件
DARWIN_LIBS = {
}

--WIN32预编译的库文件，需要copy到bin目录
WIN32_PREBUILDS = {
}

--目标文件，可以在这里定义，如果没有定义，share.mak会自动生成
OBJS = {
}

--依赖项目
DEPS = {
}