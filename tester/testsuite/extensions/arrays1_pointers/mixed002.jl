typedef struct node * tree;
struct node {
    tree[] children;
    int value;
};

int main () {
    tree f = new node;
    f->children = new tree[4];    
    
    f->children[3] = new node;
    f->children[3]->value = 1234;
    
    for(tree elem : f->children) {
        if(elem == (tree)null) {
            printString("null");
        } else {
            printString("not null");
        }
    }

    printInt(f->children[3]->value);

    return 0;
}