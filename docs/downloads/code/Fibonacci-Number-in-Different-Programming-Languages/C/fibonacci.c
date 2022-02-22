#include <stdio.h>
#include <stdlib.h>

int fib(int n) {
    if(n <= 1) {
        return n;
    }

    int a = 0;
    int b = 1;

    for(int i = 2; i <= n; i++) {
        int c = a + b;
        a = b;
        b = c;
    }
    return b;
}

int main(int argc, char *argv[]) {
    int n = atoi(argv[1]);
    printf("fib(%d) = %d\n", n, fib(n));
    return 0;
}
