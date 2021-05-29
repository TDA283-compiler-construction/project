int wow () {
    return 5;
}

class Lord {
    int wow() {
        return 10;
    }

    int a() {
        return wow();
    }
}

int main() {
    Lord lord = new Lord;

    printInt(lord.a());

    return 0;
}