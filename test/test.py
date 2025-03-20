import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cpu(dut):
    dut._log.info("Starting CPU Test")

    # Start the clock with a 20 ns period (50 MHz)
    clock = Clock(dut.clk, 20, units="ns")  # 50 MHz Clock
    cocotb.start_soon(clock.start())

    # Reset the CPU
    dut._log.info("Asserting Reset")
    dut.rst_n.value = 0
    dut.uio_in.value = 0  # Ensure write enable is low
    dut.ui_in.value = 0    # No instruction initially
    await ClockCycles(dut.clk, 10)  # Hold reset for 10 cycles

    # Enable program memory write mode
    dut._log.info("Enabling Program Memory Write Mode")
    dut.uio_in.value = 0b10000000  # uio_in[7] = 1 (Write Enable)

    # Load Instructions into Program Memory
    instructions = [
        (0b000_0000, 0b10010011), (0b000_0001, 0b00110000),
        (0b000_0010, 0b00000000), (0b000_0011, 0b00000000),

        (0b000_0100, 0b00010011), (0b000_0101, 0b00100001),
        (0b000_0110, 0b00000010), (0b000_0111, 0b00000000),

        (0b000_1000, 0b00000000), (0b000_1001, 0b00000000),
        (0b000_1010, 0b00000000), (0b000_1011, 0b00000000),

        (0b000_1100, 0b10110011), (0b000_1101, 0b00000001),
        (0b000_1110, 0b00010001), (0b000_1111, 0b00000000)
    ]

    for addr, instr in instructions:
        dut.uio_in.value = addr  # Set pmAddr
        dut.ui_in.value = instr  # Set instructionIn
        dut._log.info(f"Writing to Program Memory: Addr={addr:07b}, Instr={instr:08b}, WrEn={dut.uio_in.value.binstr}")
        await ClockCycles(dut.clk, 1)  # Wait 1 cycle per instruction

    # Disable write mode
    dut._log.info("Disabling Program Memory Write Mode")
    dut.uio_in.value = 0b00000000  # pmWrEn = 0

    # Deassert Reset to Start Execution
    dut._log.info("Deasserting Reset - Execution Begins")
    dut.rst_n.value = 1

    # Monitor instruction fetch f

