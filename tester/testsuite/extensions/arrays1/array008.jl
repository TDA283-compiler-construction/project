int[] array(int n)
{
    return new int[n];
}

int main()
{
    array(3)[2] = 1;
    printInt(array(3)[0]);
    return 0;
}
