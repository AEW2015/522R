---
title: Chisel3
taxonomy:
    category:
        - docs
visible: true
---

##Part 1

###Chisel Bootcamp Summary

The bootcamp did provide a nice interactive tutorial to understand the tools.
It introduced simple concepts of building sequential and combination logic.
It did not explain the more complicated uses of Chisel3 or Scala.
You may have to go learn scala on its own.

Here are some examples I was curious about.

~~~
// Such concision! You'll learn what all this means later.
  val taps = Seq(io.in) ++ Seq.fill(io.consts.length - 1)(RegInit(0.U(8.W)))
  taps.zip(taps.tail).foreach { case (a, b) => when (io.valid) { b := a } }

  io.out := taps.zip(io.consts).map { case (a, b) => a * b }.reduce(_ + _)

val mmap = Seq(
            RegField.r(64, nFilters.U, RegFieldDesc("nFilters", "Number of filter lanes"))
        ) ++ taps.flatMap(_.map(t => RegField(8, t, RegFieldDesc("tap", "Tap"))))

    override val mem = Some(AXI4RegisterNode(
        AddressSet(0x0, 0xffffL), beatBytes = 8
    ))
~~~



| Name  | Peek % | Concept|
| Accumulator | 0% | Reg variables and When() control logic|

Adder

0%

Generator Width

Counter

5%

Defs

DynamicMemorySearch

25%

List

LFSR16

40%

When Cat

Max2

10%

Mux, peek, poke

MaxN

30%

For reduceleft

Memo

0%

When

Mul

25%

Lookup table

Mux4

10%

Module Usage

RealGCD

50%

When

SingleEvenFilter

40%

Pipe moduels

VecShiftRegister

40%

Vec

VecShiftRegisterSimple

20%

Vec

VecShitRegisterParam

30%

Parameter For loop

VendingMachine

10%

STM

VendingMachineSwitch

40%

Switch statement Enum

ByteSelector



When, and bit selection

EnableShiftRegister

Draw

elsewhen

Functionality



Def (method/function)

HiLoMultiplier



Bit selection/multiply

LogShifter

Draw

Barrel shifter

Parity



State enum

Stack

Draw

Memory and control logic

Tbl

Draw

Lookup memory

VecSearch



Vec

Router



inheritance

Risc

Draw

Decoding instructions

Life

Draw

Class structureWhat is foldRight?
