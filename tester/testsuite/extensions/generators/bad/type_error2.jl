generator<int> generator() {
    yield 1;
}

int main() {
    for (double d : generator()) {
    }
}
