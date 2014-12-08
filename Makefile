CS := ./node_modules/coffee-script/bin/coffee
CS_FLAGS := --compile --bare

MOCHA := ./node_modules/mocha/bin/mocha
BOWER := ./node_modules/bower/bin/bower

SRC_DIR := src
TEST_DIR := test

# Glob all the coffee source
SRC := $(shell find $(SRC_DIR) -name "*.coffee" | sort)
LIB := $(SRC:%.coffee=%.js)

.PHONY: all clean test integ install

install: bower all

# Phony all target
all: $(LIB)
	@-echo "Finished building webcrawler"

# Phony rebuild target
rebuild: clean all

# Phony clean target
clean:
	@-echo "Cleaning *.js files"
	@-rm -f $(LIB)

# Runs coffee-script application
dev:
	$(CS) $(SRC_DIR)/cli.coffee

# Installs bower client js/css dependencies
bower:
	$(BOWER) install

# Runs mocha test suite
test:
	$(MOCHA) ./$(TEST_DIR)/spec_helper.coffee \
		--recursive $(TEST_DIR) \
		--compilers coffee:coffee-script/register \
		--ui bdd \
		--reporter spec \
		--colors

# Runs test suite with integration tests enabled
integ:
	$(MAKE) INTEG=true test

# Rule for all other coffee files
%.js: %.coffee
	@-echo "  Compiling $@"
	@$(CS) $(CS_FLAGS) $^

