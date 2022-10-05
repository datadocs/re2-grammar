# Re2 Antlr4 grammar

Grammar to vaidate a `re2` regular expression in compliance with: https://github.com/google/re2/wiki/Syntax/.

Test patterns taken from: https://github.com/golang/go/tree/master/src/regexp/testdata.

To test:

```
$ antlr4 Re2.g4 -o out && cd out && javac Re2*.java && java org.antlr.v4.gui.TestRig Re2 test_root ../tests/re2-exhaustive-distinct.txt ../tests/re2-search.txt && cd ..
```

