CS := ./node_modules/coffee-script/bin/coffee
CS_FLAGS := --compile --bare

MOCHA := ./node_modules/mocha/bin/mocha
BOWER := ./node_modules/bower/bin/bower

.PHONY: test prepublish integ

prepublish: bower test

test:
	$(MOCHA) ./test/spec_helper.coffee \
		--recursive ./test \
		--compilers coffee:coffee-script/register \
		--ui bdd \
		--reporter spec \
		--colors

integ:
	$(MAKE) INTEG=true test

bower:
	$(BOWER) install

