ENTITIES=ut_syndrome uc_syndrome syndrome ut_lut uc_lut lut
VCDDIR=vcd
WORKDIR=work
.NOTPARALLEL:


all: $(patsubst %,%_test.vcd,${ENTITIES})

%_test.vcd: %_test
	./$< --vcd=$(VCDDIR)/$@

%_test: %.o
	ghdl -e --workdir=$(WORKDIR) $@

%.o: src/%.vhd
	ghdl -a --workdir=$(WORKDIR) $<

clean:
	rm -f *.o $(VCDDIR)/*.vcd $(WORKDIR)/*


