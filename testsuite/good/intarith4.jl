int main () {
printInt(fact(7)) ;
printInt(factr(7)) ;
return 0 ;
}
// iterative factorial
int fact (int n) {
int i,r ;
i = 1 ;
r = 1 ;
while (i <= n) {
r = r * i ;
i++ ;
}
return r ;
}
// recursive factorial
int factr (int n) {
if (n < 2)
return 1 ;
else
return n * factr(n-1) ;
}
