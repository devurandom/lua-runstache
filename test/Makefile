DIFF:=diff -u
RUNSTACHE:=../runstache.lua

TESTS:=$(subst .cfg,,$(wildcard test*.cfg))

test01_ARGS:=-e "much more"
test02_ARGS:=-e hostname=orange
test03_ARGS:=-e cn=common-name

all: $(TESTS)

$(TESTS):
	$(RUNSTACHE) $@.cfg $@.yaml $($@_ARGS) | $(DIFF) $@.output - && echo "$@: OK" || echo "$@: FAIL"

.PHONY: all $(TESTS)
