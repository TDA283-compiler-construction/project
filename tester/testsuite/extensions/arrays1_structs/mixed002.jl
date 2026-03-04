struct Node {
    Node[] children;
    int value;
}

int main () {
    Node f = new Node;
    f.children = new Node[4];    
    
    f.children[3] = new Node;
    f.children[3].value = 1234;
    
    for(Node elem : f.children) {
        if(elem == (Node)null) {
            printString("null");
        } else {
            printString("not null");
        }
    }

    printInt(f.children[3].value);

    return 0;
}
