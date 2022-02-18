/* dereferencing an undeclared variable */

typedef struct Point2 *Point;

struct Point2 {
	int x;
	int y;
};

int main() {
	Point point = new Point2;
	point->z = 1;
	return 0;
}
