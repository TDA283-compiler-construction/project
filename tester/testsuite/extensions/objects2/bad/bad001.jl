/* overriding method has different return type */

class Vehicle {
	int speed() {
		return 10;
	}
}

class Car extends Vehicle {
	double speed() {
		return 10.0;
	}
}
	
int main() {
	return 0;	
}
