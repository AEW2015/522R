---
title: Chisel3
taxonomy:
    category:
        - docs
visible: true
---

Andy and Corbin

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
| ----------- | ----------- |----------- |
| Accumulator | 0%          | Reg variables and When() control logic|
| Adder       | 0%          | use a Generator for custom Widths     |
| Counter     | 5%          | Use Def as functions in the code      |
| DynamicMemorySearch | 25% | How to setup and use Lists            |
| LFSR16      | 40%         | Another example of when control logic and how to cat signals together |
| Max2        | 10%         | Mux function as well as expect and poke test functions|
| MaxN        | 30%         | For loops and reduceleft function examples |
| Memo        | 0%          | When control logic                    |
| Mul         | 25%         | Lookup table generation and use       |
| Mux4        | 10%         | Module Usage with a module            |
| RealGCD     | 50%         | When control logic                    |
| SingleEvenFilter | 40%    | Pipe modules together                 |
| VecShiftRegister | 40%    | Vec class usage                       |
| VecShiftRegisterSimple | 20% | Vec class usage                    |
| VecShitRegisterParam | 30% | Parameter in modules and For loop    |
| VendingMachine | 10%      | State Machine Example                 |
| VendingMachineSwitch | 40% | Switch statement Enum variable       |
| ByteSelector | -          | When, and bit selection               |
| EnableShiftRegister | Draw | elsewhen conditional usage           |
| Functionality | -         | Def (method/function) usage           |
| HiLoMultiplier | -        | Bit selection/multiply                |
| LogShifter  | Draw        | Barrel shifter mux logic              |
| Parity      | -           | State enum variable usage             |
| Stack       | Draw        | Memory and control logic              |
| Tbl         | Draw        | Lookup memory                         |
| VecSearch   | -           | Vec clase usage example               |
| Router      | -           | Class inheritance                     |
| Risc        | Draw        | Decoding instructions                 |
| Life        | Draw        | Class structure and What is foldRight? (Scala function) |
