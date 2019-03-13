/*
Semantic errors for Call expressions
* ID is not a function
* Type of paramaters does not match type of argument
* Number of parameters and arguments do not match
*/
#include<stdio.h>
int summer(int a,int b){
    return a+b;
}
int main() 
{    
    int a=0;
    a();
    float d;
    int c;
    summer(c);
    summer(c,d);
}