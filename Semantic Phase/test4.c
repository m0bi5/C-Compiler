/*
Semantic Errors for Expressions
* ID undeclared in current scope
* Array ID has no subscript
* Single variable ID or function has subscript
* Expression on rhs of assigment and in arithmetic ops must be int
*/
#include<stdio.h>
int summer(int a,int b){
    return a+b;
}
int main() 
{
    int r[];
    int a=4;
    a[0]=6;
    int c=d+1;
    summer[1]=6;
    a="asdda"+3;
}
