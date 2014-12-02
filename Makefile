CS := ./node_modules/coffee-script/bin/coffee
CS_FLAGS := --compile --bare

MOCHA := ./node_modules/mocha/bin/mocha

.PHONY: test
test:
	$(MOCHA) ./test/spec_helper.coffee \
		--recursive ./test \
		--compilers coffee:coffee-script/register \
		--ui bdd \
		--reporter spec \
		--colors \
		--watch
