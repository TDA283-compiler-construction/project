// adapted from https://www.hackerrank.com/challenges/small-triangles-large-triangles/editorial

struct Triangle
{
    int a;
    int b;
    int c;
}

int square(Triangle t)
{
    int a = t.a, b = t.b, c = t.c;
    return (a + b + c)*(a + b - c)*(a - b + c)*(-a + b + c);
}

void sort_by_square(Triangle[] a)
{
    int i = 0;
    while (i < a.length ){
        int j = i + 1; 
        while ( j < a.length ) {
            if (square(a[i]) > square(a[j]))
            {
                Triangle temp = a[i];
                a[i] = a[j];
                a[j] = temp;
            }
            j++;
        }
        i++;

    }
}

int main()
{
    int n;
    n = readInt();
    Triangle[] a = new Triangle[n];

    int i = 0;
    while( i < a.length ) {
        a[i] = new Triangle;
        Triangle t = a[i];

        t.a = readInt();
        t.b = readInt();
        t.c = readInt();

        i++;
    }
    
    sort_by_square(a);

    for (Triangle t : a) {
        printInt(t.a);
        printInt(t.b);
        printInt(t.c);    
    }
    
    return 0;
}
