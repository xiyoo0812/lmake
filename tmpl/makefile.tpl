empty:
	@echo "====No target! Please specify a target to make!"
	@echo "====If you want to compile all targets, use 'make server'"
	@echo "===='make all', which shoule be the default target is unavailable for UNKNOWN reaseon now."

CUR_DIR = $(shell pwd)/

.PHONY: clean all server {{%= FMT_GROUPS %}}

all: clean server 

server: {{%= FMT_GROUPS %}}

clean:
	rm -rf temp;

{{% for _, GROUP in pairs(GROUPS or {}) do %}}
{{%= GROUP.NAME %}}:
{{% for _, PROJECT in ipairs(GROUP.PROJECTS or {}) do %}}
	cd {{%= PROJECT.DIR %}}; make SOLUTION_DIR=$(CUR_DIR) -f {{%= PROJECT.FILE %}}.mak;
{{% end %}}


{{% end %}}

