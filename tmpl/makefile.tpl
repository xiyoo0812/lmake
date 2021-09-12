empty:
	@echo "====No target! Please specify a target to make!"
	@echo "====If you want to compile all targets, use 'make proj'"
	@echo "===='make all', which shoule be the default target is unavailable for UNKNOWN reaseon now."

CUR_DIR = $(shell pwd)/

.PHONY: clean proj all

all: clean proj

clean:
	rm -rf temp;

proj:
{{% for _, proj_info in pairs(PROJECTS or {}) do %}}
	cd {{%= proj_info.dir %}}; make SOLUTION_DIR=$(CUR_DIR) -f {{%= proj_info.file %}};
{{% end %}}

