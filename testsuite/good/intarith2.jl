int main() {
    int x;

    {
        int x = 10;
        while (x > 0) {
            printInt(x);
            x--;
        }
    }

    printInt(x);
    
    return 0;
}
    
