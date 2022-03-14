void foo()
{
    int x1 = 55555;
    int x2 = 66666;
    int x3 = 77777;
    int x4 = 88888;
    int x5 = 99999;
    int x6 = 11111;
    int x7 = 22222;
    int x8 = 33333;
}

int main()
{
    foo();
    int x;
    {
        int x = x;
        printInt(x);
        return 0;
    }
}
