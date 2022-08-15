/obj/item/paper/guides/mainframe_reference
	name = "Quick Reference to Mainframe"
	info = @{"
<H1>Quick Reference to Mainframe Programming<H1>

<H3>Getting Started</H3>
First you should get the linking tool and make sure all devices are linked to the main unit.<BR>
When programming you should check the instruction reference sheet.

<H3>Booting</H3>
When the mainframe starts it will load the address at $FFFC to begin execution at.

<H3>Memory Mapping</H3>
By default the main unit has 4kB of RAM (16 pages) at the start of the address space (from $0000 to $0FFF), after which comes the cassette drive which is also 4kB of memory (from $1000 to $1FFFF).<BR>
The next page ($2000 to $20FF) contains all peripherals linked to the mainframe, check the linker to see at which address each peripheral is.<BR>
At the end of the address space are the four pages of ROM (1kB), the address of each ROM bank is stated in the ROM unit.

<H3>Programming</H3>
To program the mainframe you take a ROM bank from the ROM unit and insert it in the ROM programmer, then you can just type your program in hexadecimal in the memory of the ROM bank.<BR>
Remember to save often.<BR>
You may also use programs written by other people by inserting your ROM bank in the ROM database and loading a pre-written program on the ROM bank.
"}
