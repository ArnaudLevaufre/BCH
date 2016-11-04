ENTITIES=ut_syndrome uc_syndrome syndrome ut_lut uc_lut lut uc_corr ut_corr corr uc_master fifo avalon bch
VCDDIR=vcd
WORKDIR=work
.NOTPARALLEL:
.PHONY: quartus rapport


all: $(patsubst %,%_test.vcd,${ENTITIES}) clean_o

test: $(patsubst %,%_test_no_assert.vcd,${ENTITIES}) clean_o

%_test_no_assert.vcd: %_test
	./$< --vcd=$(VCDDIR)/$@ --assert-level=note --ieee-asserts=disable-at-0
	cp $< ../$<

%_test.vcd: %_test
	./$< --vcd=$(VCDDIR)/$@ --ieee-asserts=disable-at-0

%_test: %.o
	ghdl -e -g --workdir=$(WORKDIR) $@

%.o: src/%.vhd
	ghdl -a --workdir=$(WORKDIR) $<

clean_o:
		rm -f *.o

clean: clean_o
	rm -f $(VCDDIR)/*.vcd $(WORKDIR)/*

quartus:
		$(MAKE) -C quartus

rapport:
		$(MAKE) -C rapport
