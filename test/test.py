import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cpu(dut):
    dut._log.info("Start CPU Test")

    # Start the clock with 10 us period (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset CPU")
    dut.rst_n.value = 0
    dut.uio_in.value = 0  # Write enable low initially
    dut.ui_in.value = 0   # No instruction initially
    await ClockCycles(dut.clk, 10)  # Wait 10 cycles during reset
    #dut.rst_n.value = 1  # Deassert reset

    # Enable write (pmWrEn)
    #dut.uio_in.value = 0b10000000  # uio_in[7] = 1 (Write Enable)

    # Load instructions into program memory
    instructions = [
        (0b1000_0000, 0b1001_0011), (0b1000_0001, 0b0011_0000),
        (0b1000_0010, 0b0000_0000), (0b1000_0011, 0b0000_0000),

        (0b1000_0100, 0b0001_0011), (0b1000_0101, 0b0010_0001),
        (0b1000_0110, 0b0000_0010), (0b1000_0111, 0b0000_0000),

        (0b1000_1000, 0b0), (0b1000_1001, 0b0),
        (0b1000_1010, 0b0), (0b1000_1011, 0b0),

        (0b1000_1100, 0b1011_0011), (0b1000_1101, 0b0000_0001),
        (0b1000_1110, 0b0001_0001), (0b1000_1111, 0b0000_0000)
    ]

    for addr, instr in instructions:
        dut.uio_in.value = addr  # Set pmAddr
        dut.ui_in.value = instr  # Set instructionIn
        await ClockCycles(dut.clk, 1)  # Wait one cycle per instruction

    # Deassert write enable
    dut.uio_in.value = 0

    # Deassert reset again (ensuring proper start)
    dut.rst_n.value = 1
    dut._log.info("Start execution")

    # Wait 1-3 cycles for execution
    await ClockCycles(dut.clk, 5)

    # Check the output (should be sum of R1 and R2)
    expected_output = 37  # Since R1 = 3, R2 = 34  → R3 = R1 + R2 = 37
    assert dut.uo_out.value == expected_output, f"Test failed: Expected {expected_output}, got {dut.uo_out.value}"

    dut._log.info(f"Test passed: Output {dut.uo_out.value.integer}")
