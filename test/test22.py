import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cpu(dut):
    dut._log.info("Starting CPU Test")

    # 50 MHz clock (20 ns period)
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # Reset the CPU
    dut._log.info("Asserting Reset")
    dut.rst_n.value = 0
    dut.uio_in.value = 0  # Write enable low
    dut.ui_in.value = 0    # No instruction initially
    await ClockCycles(dut.clk, 10)

    # Enable program memory write mode
    dut._log.info("Enabling Program Memory Write Mode")
    dut.uio_in.value = 0b10000000  # pmWrEn = 1

    # Load Instructions (Debugging Logs Added)
    instructions = [
        (0b000_0000, 0b10010011), (0b000_0001, 0b00110000),
        (0b000_0010, 0b0), (0b000_0011, 0b0),

        (0b000_0100, 0b00010011), (0b000_0101, 0b00100001),
        (0b000_0110, 0b0), (0b000_0111, 0b0),

        (0b000_1000, 0b0), (0b000_1001, 0b0),
        (0b000_1010, 0b0), (0b000_1011, 0b0),

        (0b000_1100, 0b10110011), (0b000_1101, 0b00000001),
        (0b000_1110, 0b000100001), (0b000_1111, 0b0)
    ]

    for addr, instr in instructions:
        dut.uio_in.value = addr  # Set pmAddr
        dut.ui_in.value = instr  # Set instructionIn
        await ClockCycles(dut.clk, 1)
        dut._log.info(f"Writing to pmAddr {addr:07b}: Instruction = {instr:08b}")

    # Disable write mode
    dut._log.info("Disabling Program Memory Write Mode")
    dut.uio_in.value = 0b00000000  # pmWrEn = 0

    # Extra delay to stabilize before execution
    await ClockCycles(dut.clk, 5)

    # Deassert Reset
    dut._log.info("Deasserting Reset - Execution Begins")
    dut.rst_n.value = 1

    # Extra cycles for execution
    await ClockCycles(dut.clk, 10)

    # Debug ALU Input Values
    dut._log.info("Fetching ALU Input Values")
    try:
        data1 = dut.user_project.alu.data1.value.integer
        data2 = dut.user_project.alu.data2.value.integer
        dut._log.info(f"ALU Input 1 (data1): {data1}")
        dut._log.info(f"ALU Input 2 (data2): {data2}")
    except AttributeError:
        dut._log.warning("ALU signals not directly accessible! Check hierarchy!")

    # Check Register Values
    try:
        R1 = dut.user_project.register_file.reg_array[1].value.integer
        R2 = dut.user_project.register_file.reg_array[2].value.integer
        R3 = dut.user_project.register_file.reg_array[3].value.integer
        dut._log.info(f"Register R1: {R1}")
        dut._log.info(f"Register R2: {R2}")
        dut._log.info(f"Register R3: {R3}")
    except AttributeError:
        dut._log.warning("Register file signals not directly accessible! Check hierarchy!")

    # Check ALU output
    dut._log.info("Checking ALU Output after ADD Operation")
    result = dut.uo_out.value.integer
    dut._log.info(f"Final ALU Output (R3): {result}")

    assert result == 5, f"Test failed! Expected R3 = 5, but got {result}."

    dut._log.info("CPU Test Completed Successfully")

