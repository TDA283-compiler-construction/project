generator<int> squares(int end) {
    int i = 0;
    while (i < end) {
        yield i*i;
        i++;
    }
}

int main() {
    for (int i : squares(10)) {
        printInt(i);
    }
    return 0;
}
