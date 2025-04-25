/* dereferencing an undeclared variable */

struct Point {
	int x;
	int y;
};

int main() {
	Point point = new Point;
	point->z = 1;
	return 0;
}
