
int main()
{
    /* 2D array with 3 rows. rows are uninitialized (0-length arrays) */
    int[][] M = new int[][3];

    printInt(M.length); // should print 3

    for(int[] row : M) {
        printInt(row.length); // should print 0
    }

    return 0;
}