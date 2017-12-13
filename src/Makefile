# Create firmware

FORTH = /usr/local/opt/SwiftForth/bin/osx/sf
#FORTH = gforth -e

VPATH = ../j1_forth

SRC = crossj1.fs \
      basewords.fs \
      nuc.fs \
      application.fs \
      main.fs

.PHONY: sim syn

j1.mif j1.hex j1.lst: $(SRC)
	$(FORTH) main.fs

sim: j1.hex j1.mif
	cp $^ ../sim

syn: j1.mif
	cp $^ ../syn
