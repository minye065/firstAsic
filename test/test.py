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

async def transaction(handle, opcode, a, b):
    handle.ui_in.value = handle.ui_in.value = 0
    await ClockCycles(handle.clk, 4)
    await sendByte(handle, opcode)
    await sendByte(handle, a)
    await sendByte(handle, b)
    result = 0
    for _ in range(8):
        handle.ui_in.value = 0
        await ClockCycles(handle.clk, 8)
        miso = int(handle.uo_out.value) & 1
        result = (result << 1) | miso
        handle.ui_in.value = 1
        await ClockCycles(handle.clk, 8)
        handle.ui_in.value = 0
    handle.ui_in.value = 2
    return result


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
    result = await transaction(dut, 0, 1, 2);
    dut._log.info(f"result = {result}")
    assert result == 3
    await ClockCycles(dut.clk, 8);