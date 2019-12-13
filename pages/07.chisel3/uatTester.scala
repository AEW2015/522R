package hw

import java.io.File
import chisel3._
import chisel3.iotesters
import chisel3.iotesters.{ChiselFlatSpec, Driver, PeekPokeTester}

class uatTester(c: uat) extends PeekPokeTester(c) {

  for(_ <- 0 until 10){


  val data =  rnd.nextInt(256)
  val dataList = List((data>>0)&1,
                      (data>>1)&1,
                      (data>>2)&1,
                      (data>>3)&1,
                      (data>>4)&1,
                      (data>>5)&1,
                      (data>>6)&1,
                      (data>>7)&1,
                      1,
                    )

  expect(c.io.tx_busy,0)
  poke(c.io.data,data.U(8.W))
  expect(c.io.tx,1)
  poke(c.io.send,1)
  step(2700)
  print("[LOG] sending ==>  " + data.U(8.W) + "\n")
  println("start bit")
  poke(c.io.send,0)
  expect(c.io.tx_busy,1)
  expect(c.io.tx,0)
  step(5208)
  println("data bit 0")
  expect(c.io.tx_busy,1)
  expect(c.io.tx,dataList(0))
  step(5208)
  expect(c.io.tx_busy,1)
  expect(c.io.tx,dataList(1))
  step(5208)
  expect(c.io.tx_busy,1)
  expect(c.io.tx,dataList(2))
  step(5208)
  expect(c.io.tx_busy,1)
  expect(c.io.tx,dataList(3))
  step(5208)
  expect(c.io.tx_busy,1)
  expect(c.io.tx,dataList(4))
  step(5208)
  expect(c.io.tx_busy,1)
  expect(c.io.tx,dataList(5))
  step(5208)
  expect(c.io.tx_busy,1)
  expect(c.io.tx,dataList(6))
  step(5208)
  expect(c.io.tx_busy,1)
  expect(c.io.tx,dataList(7))
  step(5208)
  println("parity bit 0")
  expect(c.io.tx_busy,1)
  expect(c.io.tx,dataList.reduce(_^_))
  step(5208)
  println("stop bit 0")
  expect(c.io.tx_busy,0)
  expect(c.io.tx,1)
}

}
