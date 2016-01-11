.PHONY: test integ

# Runs mocha test suite
test:
	./node_modules/.bin/mocha ./test/spec_helper.coffee \
		--recursive ./test \
		--compilers coffee:coffee-script/register \
		--ui bdd \
		--reporter spec \
		--colors

# Runs test suite with integration tests enabled
integ:
	$(MAKE) INTEG=true test
