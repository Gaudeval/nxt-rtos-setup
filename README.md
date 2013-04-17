About
=====

This project provides scripts and files to setup and run [trampoline][]-based
applications for LEGO&reg; Mindstorms&reg; bricks under Unix systems.

* `trampoline.build` is used to download and build the [trampoline][] real-time
	operating system, and the goil application for application oil description files
	parsing. Files are installed under the `trampoline/` folder by default.

* `gcc.build` is used to download and build the [gcc][] compiler and its
	dependencies for the nxt arm-elf architecture. Files are installed under the
	`gcc-arm-elf/` folder by default.

	Credits go to Uwe Hermann <uwe@hermann-uwe.de> and Piotr Esden-Tempski
	<piotr@esden.net> for the [original script][1].

* `scripts` holds helper scripts for application creation, compilation and
	upload to nxt bricks.

	`nxt_create` creates a new application, c source file and oil description,
	from predefined templates (see the `app_template/` folder).
	
	`nxt_goil` generates a Makefile for an application given its description in
	the oil format and the `goil` application. 

	`nxt_reenv` alters an oil description file to befit compilation under the
	current environment, [trampoline][] and [gcc][]. A `_`-prefixed copy of the
	original is saved.

	`nxt_send` uploads files to a nxt brick through connected through USB, relying
	on the `nexttool` application for operations.

* `env_setup` is a sh script sourced to setup the environment variables used by
	nxt_* scripts:
	+ trampoline installation path (defaults to `trampoline/`),
	+ gcc arm-elf installation path (defaults to `gcc-arm-elf/`),
	+ `nxt_create` template files (defaults to `app_template/`),
	+ and adds the `nexttool`, `goil`, nxt_* and gcc binaries to the path.

* `nexttool` holds a precompiled version of the [nexttool][] application used to
	communicate with nxt bricks under Linux systems. Mac OSX users can use the
	[graphical NeXT Tools
	interface](http://bricxcc.sourceforge.net/utilities.html).

These scripts have been tested under Mac OSX 10.6 and a Linux 2.6.35 Gentoo.
Note that, under Linux, users require the write access on a nxt brick device to
upload files.

TODO
====

* `nexttool.build` is missing. Finding an elegant way to assert the presence of
	a Pascal compiler, or to automate the installation of one, is the main issue.

* `nxt_send`, when uploading a file, should check for the presence of a file
	with the same name and account for its size as free space when ensuring that
	there is enough room on the brick for the uploaded file. As of now, files with
	the same name than the uploaded one are first erased from the brick, before
	checking the free space.

* `env_setup` relies on bash `BASH_SOURCE` to guess the environment root
  directory. A more posix-compliant method is desirable.


[trampoline]: http://trampoline.rts-software.org/
	"Trampoline open-source real-time operating system." 

[gcc]: http://gcc.gnu.org/

[nexttool]: http://bricxcc.sourceforge.net/

[1]: https://github.com/esden/summon-arm-toolchain
