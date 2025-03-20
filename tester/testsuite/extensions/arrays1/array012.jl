int main() {
    arr(3)[0]++;
    arr(5)[1]--;

    return 0;
}

int[] arr(int n) {
    printInt(n);
    return new int[n];
}
