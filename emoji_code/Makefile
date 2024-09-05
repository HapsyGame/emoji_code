.PHONY: all check clean run run_debug

ARGS := $(filter-out $@ run,$(MAKECMDGOALS))

all:
	@flex emoji_compilator.l
	@bison -d -Wcounterexamples emoji_compilator.y
	@gcc lex.yy.c emoji_compilator.tab.c -o emoji_compilator
	@rm -f lex.yy.c emoji_compilator.tab.*

check: all
	@if [ -e hapsycode ]; then \
	rm -f ./hapsycode; \
	fi
	@./emoji_compilator $(ARGS) > hapsycode.c
	# @gcc hapsycode.c -o hapsycode > /dev/null 2>&1 || true
	./compile.sh hapsycode.c || true
	@if [ -e hapsycode ]; then \
	./hapsycode || true; \
	fi

debug_check: all
	if [ -e hapsycode ]; then \
	rm -f ./hapsycode; \
	fi
	./emoji_compilator exemple.ej > hapsycode.c
	gcc hapsycode.c -o hapsycode
	cat hapsycode.c
	if [ -e hapsycode ]; then \
	./hapsycode; \
	fi

clean:
	@rm -f emoji_compilator emoji_compilator.c hapsycode hapsycode.c

run: clean all check

run_debug: clean all debug_check
