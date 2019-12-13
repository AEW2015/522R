package hw

import  chisel3._

object uatMain extends App {
  iotesters.Driver.execute(args, () => new uat(100000000,19200)){
    c => new uatTester(c)
  }
  // Alternate version if there are no args
  // chisel3.Driver.execute(Array[String](), () => new HelloWorld)
}
