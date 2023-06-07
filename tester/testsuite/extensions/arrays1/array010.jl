int main() {
    int[] xs = new int[5];

    xs[2]--;
    xs[1]++;

    for(int x : xs)
        printInt(x);

    return 0;
}
