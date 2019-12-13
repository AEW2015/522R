// See LICENSE.txt for license details.
package hw

import chisel3._
import chisel3.util._
//clk_rate/baud_rate-1
class uat(val clk_rate: Int, val baud_rate: Int) extends Module {
  val io = IO(new Bundle{
  val send = Input(UInt(1.W))
  val data = Input(UInt(8.W))
  val tx_busy = Output(UInt(1.W))
  val tx = Output(UInt(1.W))
  })
  val bit_count_max = clk_rate/baud_rate-1
  val bit_count_bits = log2Ceil(bit_count_max)
  val bit_timer = RegInit(0.U(bit_count_bits.W))
  val clr_timer = RegInit(false.B)
  val data_2_send = RegInit(0.U(8.W))
  val index = RegInit(0.U(4.W))
  val parity = RegInit(0.U(1.W))
  val tx_reg = RegInit(1.U)

  val tx_flag = (bit_timer === bit_count_max.asUInt)

  when(clr_timer || bit_timer === bit_count_max.asUInt){
     bit_timer := 0.U
  }.otherwise{
    bit_timer := bit_timer + 1.U
  }

  val sIdle :: sData :: sParity :: sDone :: Nil = Enum(4)
  val state = RegInit(sIdle)


  io.tx_busy := 0.U
  io.tx := tx_reg
  clr_timer := false.B

  when (state === sIdle){
      when(io.send === 1.U){
          clr_timer := true.B
          tx_reg := 0.U
          data_2_send := io.data
          index := 0.U
          parity := 1.U
          state := sData

      }
  }

  when (state === sData){
  io.tx_busy := 1.U
    when ( tx_flag === 1.U){
      tx_reg := data_2_send(index)
      parity := data_2_send(index)^parity

      when (index === 7.U){
        state := sParity
      }

      index := index + 1.U
    }
  }

when (state === sParity){
io.tx_busy := 1.U
when ( tx_flag === 1.U){
  tx_reg := parity
  state := sDone
}
}

when (state === sDone){
io.tx_busy := 1.U
    when(tx_flag === 1.U){
        tx_reg := 1.U
        state := sIdle
    }
}


}
