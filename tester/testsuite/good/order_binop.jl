
int main() {

    int x;
    
    x = f(1) - f(2);
    x = f(3) + f(4);
    x = f(5) * f(6);
    x = f(7) / f(8);
    x = f(9) % f(2);
 
    printInt(f(12) + f(34));

    return 0;
}

int f(int x) {
    printInt(x);
    return x;
}