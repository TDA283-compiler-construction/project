generator<int> range(int start, int end) {
    int i = start;
    while (i < end) {
        yield i;
        i++;
    }
}

generator<int> range0(int end) {
    return range(0,end);
}

int main() {
    for (int i : range0(10)) {
        printInt(i);
    }
    return 0;
}
