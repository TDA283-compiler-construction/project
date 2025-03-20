int main() {
    int[][] xss = new int[2][3];

    xss[0][1]--;
    xss[1][0]++;

    for(int[] xs : xss)
        for(int x : xs)
            printInt(x);

    return 0;
}
