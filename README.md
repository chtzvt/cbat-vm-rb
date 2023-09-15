# CBAT Batch VM

Welcome to the CBAT (**C**ompiled **Bat**ch) language virtual machine, Ruby edition.

CBAT (pronounced "see-bat") is a toy language that's interpreted by a virtual machine. This is the Ruby implementation of the virtual machine.

## Purpose 

The intention behind CBAT is to provide a portable, cross-platform language that can be used as a compilation target for old [Batchfile proograms](https://github.com/chtzvt/X-DOS-BBS) I wrote when I was a kid.

I haven't gotten to writing a Batchfile->CBAT compiler yet, but it's on the bucket list. In the meantime, I've been compiling [Batchfile programs](https://github.com/chtzvt/X-DOS-BBS) into [CBAT](https://github.com/chtzvt/cbat-vm-rb/blob/master/tests/chatserver.cbat) by hand.

CBAT's not intended to be a serious language, but rather a fun project to learn about virtual machines and language design. You can learn more about the CBAT language by reviewing the [documentation](https://github.com/chtzvt/cbat-vm-rb/blob/master/instruction_set.md) and [examples](https://github.com/chtzvt/cbat-vm-rb/tree/master/tests) I've written for fun and testing.

You can execute these like so:

```bash 
ruby ./exec.rb ./tests/prime.cbat 
```

Which will output `6857`.

## Features

The CBAT VM and language have been designed specifically to acommodate the needs of the [X-DOS BBS](https://github.com/chtzvt/X-DOS-BBS) and its sibling projects. 

At the time, I was writing a lot of Batchfile programs and followed some conventions that I've tried to preserve in CBAT (such as using the filesystem as a global key-value store, and splitting programs into callable batch files with a shared global namespace for variables).

CBAT includes a number of useful features, including: 

- An integrated debugger: Invokable using the `bp` instruction, or by setting the `debug` flag in the `.header` section of your CBAT program.

- In-memory key-value store: CBAT programs can read and write to a global key-value store that's persisted in memory.

- Global variables: CBAT programs can read and write to a global namespace of variables. 

- String interpolation: Just like in Batch, CBAT supports string interpolation in many contexts using `%IDENTIFIER%`. You can even use this syntax to provide dynamic arguments to certain instructions, and to concatenate strings.

- Basic math: CBAT supports basic math operations, including addition, subtraction, multiplication, division, and modulus.

## Future Work

CBAT is almost ready to host my Batch programs, but needs a little more in the way of features and polish. Once the compiler is ready, I'll be able to run my old Batch BBS on modern systems (and even serve it over the Internet via SSH!).

## Further Reading 

If you'd like to learn about real-world virtual machines powering serious programming languages, I recommend reading Kevin Newton's [Advent of YARV](https://kddnewton.com/2022/11/30/advent-of-yarv-part-0.html) series about Ruby's YARV virtual machine.