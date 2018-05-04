all: Grade

Grade: *.hs
	ghc -threaded --make Grade.hs
clean:
	rm -f *.{hi,o} Grade

distrib:
	rm -r tester ; true
	git clone . tester
	rm -rf tester/.git tester/.gitignore tester/report ; tester/*.py ; true
	tar -czf tester.tar.gz tester
