int main() {
    if(1 < 6 || no()) {
        printInt(1);
    }
    if(2+2 != 4 && no()) {
        printInt(2);
    }
    if(5 < 5 || yes()) {
        printInt(3);
    }
    if(0.4 >= 0.3 && yes()) {
        printInt(4);
    }
    return 0;
}

boolean no() {
    printString("no");
    return false;
}

boolean yes() {
    printString("yes");
    return true;
}
