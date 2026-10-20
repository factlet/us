# Runs factlet from its checkout next to this one; set FACTLET to use another.
FACTLET ?= cargo run -q --release --features cli --manifest-path $(CURDIR)/../factlet/Cargo.toml --

# Every directory with a main.lisp is a program.
PROGRAMS := $(patsubst %/main.lisp,%,$(wildcard */main.lisp))
CHECKS := $(addprefix check-,$(PROGRAMS))
TESTS := $(addprefix test-,$(PROGRAMS))

.PHONY: check test $(CHECKS) $(TESTS)

check: $(CHECKS)
test: $(TESTS)

# Each runs from its program's directory, where its includes resolve.
$(CHECKS): check-%:
	cd $* && $(FACTLET) check main.lisp
$(TESTS): test-%:
	cd $* && $(FACTLET) test main.lisp tests/
