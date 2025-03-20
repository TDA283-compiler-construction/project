/* redefinition with different type */

typedef struct Point2* Point;
typedef struct Point3* Point;

struct Point {
    int x;
};

int main () {
    return 1;
}
