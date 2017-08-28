OUTPUT_ARCH( "riscv" )
SECTIONS
{
  . = 0x10000000;
  .text : { *(.text) }
}
