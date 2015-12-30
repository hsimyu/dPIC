OBJS = local_const.o physical_const.o particle.o grid.o plasma_init.o
DD = dmd
DFLGS = # -w -g -debug=2 -de -boundscheck=on -gx

.SUFFIXES: .d .o
main: main.d $(OBJS)
	$(DD) $(DFLGS) main.d $(OBJS) -ofmain.out

.d.o:
	$(DD) $(DFLGS) -c $<

clean:
	rm -f ./*.o ./main
