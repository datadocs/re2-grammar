# Re2 Antlr4 grammar

Grammar to vaidate a `re2` regular expression in compliance with: https://github.com/google/re2/wiki/Syntax/.

To test:

```
$ antlr4 Re2.g4 -o out && cd out && javac Re2*.java
$ java org.antlr.v4.gui.TestRig Re2 test_root ../test_regex.txt
```

