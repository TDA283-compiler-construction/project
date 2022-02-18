/* invalid depth when indexing */

int main() {
	int[][] array = new int[10][10];
	printInt(array[0][0][0]);
	return 0;
}
