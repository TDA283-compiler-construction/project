// adapted from https://www.hackerrank.com/challenges/small-triangles-large-triangles/editorial

struct Triangle
{
    int a;
    int b;
    int c;
};

typedef struct Triangle * PTriangle;

int square(PTriangle t)
{
    int a = t->a, b = t->b, c = t->c;
    return (a + b + c)*(a + b - c)*(a - b + c)*(-a + b + c);
}

void sort_by_square(PTriangle[] a)
{
    int i = 0;
    while (i < a.length ){
        int j = i + 1; 
        while ( j < a.length ) {
            if (square(a[i]) > square(a[j]))
            {
                PTriangle temp = a[i];
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
    PTriangle[] a = new PTriangle[n];

    int i = 0;
    while( i < a.length ) {
        a[i] = new Triangle;
        PTriangle pt = a[i];

        pt->a = readInt();
        pt->b = readInt();
        pt->c = readInt();

        i++;
    }
    
    sort_by_square(a);

    for (PTriangle pt : a) {
        printInt(pt->a);
        printInt(pt->b);
        printInt(pt->c);    
    }
    
    return 0;
}
