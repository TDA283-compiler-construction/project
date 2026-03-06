generator<int> range(int start, int end) {
    int i = start;
    while (i < end) {
        yield i;
        i++;
    }
}

int main() {
    for (int i : range(0,10)) {
        printInt(i);
    }
    return 0;
}
