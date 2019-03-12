rm parser.tab.c
flex lexer.l
bison parser.y
gcc parser.tab.c -L"C:\GnuWin32\lib" -lfl -ly -w
./a.exe test1.c