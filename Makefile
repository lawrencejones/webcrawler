CS := ./node_modules/coffee-script/bin/coffee
CS_FLAGS := --compile --bare

MOCHA := ./node_modules/mocha/bin/mocha

.PHONY: test set-integ
test:
	$(MOCHA) ./test/spec_helper.coffee \
		--recursive ./test \
		--compilers coffee:coffee-script/register \
		--ui bdd \
		--reporter spec \
		--colors \
		--watch

integ:
	$(MAKE) INTEG=true test

