class Cool {

    int func1() {
        return 5;
    }

    int func2() {
        return 10;
    }

}

int main() {

    Cool a = new Cool;

    int x = a.(func1() + func2());
    int y = a.(func1() * 50);
    int z = a.(func2() - 3);

    return 0;
}