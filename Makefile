ENTITIES=ut_syndrome uc_syndrome syndrome ut_lut uc_lut lut uc_master fifo avalon corr bch
VCDDIR=vcd
WORKDIR=work
.NOTPARALLEL:


all: $(patsubst %,%_test.vcd,${ENTITIES}) clean_o

test: $(patsubst %,%_test_no_assert.vcd,${ENTITIES}) clean_o

%_test_no_assert.vcd: %_test
	./$< --vcd=$(VCDDIR)/$@ --assert-level=note

%_test.vcd: %_test
	./$< --vcd=$(VCDDIR)/$@

%_test: %.o
	ghdl -e --workdir=$(WORKDIR) $@

%.o: src/%.vhd
	ghdl -a --workdir=$(WORKDIR) $<

clean_o:
		rm *.o

clean: clean_o
	rm -f $(VCDDIR)/*.vcd $(WORKDIR)/*

