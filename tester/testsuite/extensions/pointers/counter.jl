struct Counter {
    int n;
};

typedef struct Counter* Counter;

void inc(Counter c) {
    (c->n)++;
}

void dec(Counter c) {
    (c->n)--;
}

void show(Counter c) {
    printInt(c->n);
}

int main() {
    Counter c = new Counter;
    show(c);
    inc(c);
    inc(c);
    show(c);
    dec(c);
    show(c);
    inc(c);
    show(c);

    return 0;
}
