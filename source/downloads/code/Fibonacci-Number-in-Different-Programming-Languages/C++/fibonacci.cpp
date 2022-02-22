#include <iostream>

using namespace std;

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
    cout << "fib(" << n << ")" << " = " <<  fib(n) << endl;
    return 0;
}
