.PHONY: all
all:
	riscv32-unknown-elf-gcc -static -nostdlib -nostartfiles empty.S -o empty.o
	riscv32-unknown-elf-gcc -g -Og -T empty.lds -nostartfiles -o empty empty.o
	nohup spike -H --rbb-port=9824 -m0x10000000:0x20000 empty > spike.log & \
		echo $$! > spike.pid
	nohup openocd -f spike.cfg > openocd.log & echo $$! > openocd.pid
	riscv32-unknown-elf-gdb empty --command=gdb.cfg
	kill -9 $$(cat openocd.pid) || true
	kill -9 $$(cat spike.pid) || true
	rm -f openocd.pid spike.pid 

.PHONY: clean
clean:
	rm -f openocd.pid openocd.log spike.pid spike.log empty empty.o
