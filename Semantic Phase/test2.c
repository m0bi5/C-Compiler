/*
Semantic errors for Function declarations
* Duplicate declaration of ID
* Params of type void
* No functions defined
* Int function has void return
* Void function has int return
*/

#include<stdio.h>
int sum(){
    return 1;
}
int sum(){
    return 2;
}
int voider(void t){
    return ;
}
void inter(int a){
    return a;
}
int main() 
{
    minter();
    return 0;
}