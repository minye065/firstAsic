import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

async def sendByte(handle, byte):
    for i in range(7, -1, -1):
        bit = (byte >> i) & 1
        handle.ui_in.value = bit << 2
        await ClockCycles(handle.clk, 8)
        handle.ui_in.value = (bit << 2) | 1  #here
        await ClockCycles(handle.clk, 8)
        handle.ui_in.value = bit << 2

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 2
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut.ui_in.value = 0
    await sendByte(dut, 0xA5)
