# Create firmware

FORTH=/usr/local/opt/SwiftForth/bin/osx/sf
#FORTH=gforth -e

j1.mif j1.hex j1.lst: *.fs Makefile
	$(FORTH) main.fs

sim: j1.hex
	cp $< ../sim

syn: j1.mif
	cp $< ../syn
