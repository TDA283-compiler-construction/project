typedef struct Cool* Cool_P;

struct Cool {
    int cool;
};

void wow() {

}

int main() {

    Cool_P p = new Cool;

    int a = 0;

    int c = p->(cool + 5);
    int d = p->(cool - 5);
    int e = p->(0 + cool);

    return 0;
}