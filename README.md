# Execute Raw RISC-V Machine Code with Spike

The code in this repo allows execution of raw (non-ELF) binary files as RISC-V
instructions through `spike`/`openocd`/`gdb`. With simple modifications it
should be possible to use other raw formats such as `ihex` and `srec` files.

## Environment

The `Makefile` assumes the RISC-V 32-bit IMA toolchain has been built and is in
your `PATH`. The included `Vagrantfile` will build the toolchain within Debian
9 if needed. To use the `Vagrantfile` first install `vagrant`, then issue a
`vagrant up` command to build the toolchain in a virtual machine.

## Running

Simply issuing a `make` command in the repository directory will build all of
the needed files, launch `spike`/`openocd`/`gdb`, and execute the binary file as
code. The provided `gdb.cfg` is configured to be fully automatic, just to prove
everything works. You'll probably want to remove the `quit` instruction from
`gdb.cfg` in order to leave the `gdb` interactive session up and running.

To run through `vagrant` you can use `vagrant ssh -c "cd /vagrant && make"` to
run the `make` command in the correct directory inside the virtual machine
containing the toolchain.

## Files

* `empty.S` is a minimal RISC-V assembly program with a single `nop`
  instruction in the .text section. The `_start` global points to this `nop`
  instruction.  This exists just so `spike` has something to load, the code in
  it is not executed.
* `empty.lds` is a simple linker script that specifies the `riscv` architecture
  and places the `.text` section at address `0x10000000`. This exists just so
  `spike` has something to load, the code in it is not executed.
* `spike.cfg` is an `openocd` configuration file that specifies how `openocd`
  should connect to `spike`.
* `gdb.cfg` is a list of `gdb` commands that specify how `gdb` should connect to
  `openocd` and how it should load and execute the binary program.
* `program.bin` is a set of RISC-V instructions in binary. It assigns a different
  value to each temporary general purpose register using the `LUI` and `SRLI`
  instructions.  This is the code that we want to execute.
* `Makefile` is the recipe for how all of the other files work together.
* `Vagrantfile` is the recipe for how to install the RISC-V 32-bit IMA
  toolchain.
* `.gitignore` is used to ignore all output files.
* `README.md` is this file that you're reading right now!
* `LICENSE` specifies that this repository is under the GPL v3.0 license.

## How it works

First, the `empty.S` assembly code is compiled into an object file `empty.o`.
Next, `empty.o` is linked into an ELF executable named `empty` using the
`empty.lds` linker script. Now we have a minimal ELF file that can be loaded by
`spike`.

Next, the `empty` executable is fed to `spike` which is given a memory region
at `0x10000000` and told to await an `openocd` remote bit-bang connection on
port 9284.

After `spike` is running we start an `openocd` session to `spike` using the
`spike.cfg` `openocd` configuration file.

Finally we launch `gdb` and using the `gdb.cfg` file we issue commands to `gdb`
that tell it to connect to `openocd`, load `program.bin` at address `0x10000000`,
and start executing it.

The `gdb.cfg` here sets a breakpoint after the last instruction, and once the
breakpoint is hit it shows the register information to make sure the
instructions were executed correctly.

## Program

The `program.bin` file contains the following assembly instructions.
Essentially, the "program" assigns 0 to t0, 1 to t1, etc. up to t6.

```
lui t0, 0
srli t0, t0, 12
lui t1, 1
srli t1, t1, 12
lui t2, 2
srli t2, t2, 12
lui t3, 3
srli t3, t3, 12
lui t4, 4
srli t4, t4, 12
lui t5, 5
srli t5, t5, 12
lui t6, 6
srli t6, t6, 12
```

## Sample Output

```
$ make
riscv32-unknown-elf-gcc -static -nostdlib -nostartfiles empty.S -o empty.o
riscv32-unknown-elf-gcc -g -Og -T empty.lds -nostartfiles -o empty empty.o
nohup spike -H --rbb-port=9824 -m0x10000000:0x20000 empty > spike.log & \
	echo $! > spike.pid
nohup openocd -f spike.cfg > openocd.log & echo $! > openocd.pid
nohup: redirecting stderr to stdout
riscv32-unknown-elf-gdb empty --command=gdb.cfg
nohup: redirecting stderr to stdout
GNU gdb (GDB) 8.0.50.20170808-git
Copyright (C) 2017 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "--host=x86_64-pc-linux-gnu --target=riscv32-unknown-elf".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from empty...(no debugging symbols found)...done.
0x00000000 in ?? ()
=> 0x00000000:	Cannot access memory at address 0x0
Loading section .text, size 0x4 lma 0x10000000
Start address 0x10000000, load size 4
Transfer rate: 102 bytes/sec, 4 bytes/write.
Restoring binary file program.bin into memory (0x10000000 to 0x10000038)
Breakpoint 1 at 0x10000038
ra             0x00000000	0
sp             0x00000000	0
gp             0x00000000	0
tp             0x00000000	0
t0             0x00000000	0
t1             0x00000000	0
t2             0x00000000	0
fp             0x00000000	0
s1             0x00000000	0
a0             0x00000000	0
a1             0x00000000	0
a2             0x00000000	0
a3             0x00000000	0
a4             0x00000000	0
a5             0x00000000	0
a6             0x00000000	0
a7             0x00000000	0
s2             0x00000000	0
s3             0x00000000	0
s4             0x00000000	0
s5             0x00000000	0
s6             0x00000000	0
s7             0x00000000	0
s8             0x00000000	0
s9             0x00000000	0
s10            0x00000000	0
s11            0x00000000	0
t3             0x00000000	0
t4             0x00000000	0
t5             0x00000000	0
t6             0x00000000	0
pc             0x10000000	268435456

Breakpoint 1, 0x10000038 in ?? ()
=> 0x10000038:	00 00	unimp
ra             0x00000000	0
sp             0x00000000	0
gp             0x00000000	0
tp             0x00000000	0
t0             0x00000000	0
t1             0x00000001	1
t2             0x00000002	2
fp             0x00000000	0
s1             0x00000000	0
a0             0x00000000	0
a1             0x00000000	0
a2             0x00000000	0
a3             0x00000000	0
a4             0x00000000	0
a5             0x00000000	0
a6             0x00000000	0
a7             0x00000000	0
s2             0x00000000	0
s3             0x00000000	0
s4             0x00000000	0
s5             0x00000000	0
s6             0x00000000	0
s7             0x00000000	0
s8             0x00000000	0
s9             0x00000000	0
s10            0x00000000	0
s11            0x00000000	0
t3             0x00000003	3
t4             0x00000004	4
t5             0x00000005	5
t6             0x00000006	6
pc             0x10000038	268435512
A debugging session is active.

	Inferior 1 [Remote target] will be detached.

Quit anyway? (y or n) [answered Y; input not from terminal]
kill -9 $(cat openocd.pid) || true
kill -9 $(cat spike.pid) || true
rm -f openocd.pid spike.pid 
```
