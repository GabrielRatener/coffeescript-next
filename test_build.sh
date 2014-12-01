#!/bin/sh
cd src
coffee -c -o ../lib/coffee-script/ browser.coffee grammar.coffee nodes.coffee rewriter.coffee cake.coffee helpers.coffee optparse.coffee scope.litcoffee coffee-script.coffee index.coffee register.coffee sourcemap.litcoffee command.coffee lexer.coffee repl.coffee