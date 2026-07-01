<img width="1500" height="495" alt="SPI MODES" src="https://github.com/user-attachments/assets/cfed1a54-7536-4b90-b91f-211148095a9b" />
<img width="1365" height="572" alt="SPI" src="https://github.com/user-attachments/assets/8a276f9c-80ff-4d02-a995-9eba4e024e01" />
# SPI-Verification
Designed an complete SPI system from scratch, consisting of its RTL and Testbench , consisting of Self-Checking testbench with 3 test cases.
SPI Master Design (Verilog)
Overview

This project implements an SPI (Serial Peripheral Interface) Master design in Verilog and verifies its functionality using a self-checking testbench. The design follows FSM-based control logic and shift register-based serial communication.

Project Highlights
1.SPI Master RTL implemented in Verilog
2.FSM-based controller
3.Shift register-based serial communication
  Self-checking testbench with 3 test cases
Test Results: All tests passed
  Waveforms were checked bit by bit to manually verify that every transmitted and received bit shifted correctly for a clearer understanding of the protocol.
1.SPI Protocol Basics
CPOL → what clock level stays during idle.
CPHA → which clock edge samples data.
Receiver should sample after data becomes stable, not while changing.
CPHA behavior

CPHA = 0

Data sampled on: 1st clock edge
Data changes on: 2nd clock edge

CPHA = 1

Data sampled on: 2nd clock edge
Data changes on: 1st clock edge

When data is allowed to change → Shift edge
When data must be read → Sample edge

About the SPI Data Lines,
1.TX (MOSI)
Converts parallel incoming data into serial data.
SPI sends one bit at a time (one bit per clock).
Hence, a shift register is used.
2.RX (MISO)
Converts serial data back to parallel data.
Whatever the slave sends, the master should reconstruct it.
MOSI → carries transmitted data
MISO → carries received data

3.FSM Design Used

FSM states I followed:

IDLE
LOAD
SHIFT
CHECK
DONE

Verification Test Cases used, 
Master sends 0xA5, Slave sends 0x3C
Master sends 0xFF, Slave sends 0x3C
Master sends 0x00, Slave sends 0xA5

Result: ✅ All test cases passed.

Design Checks Performed

To verify functionality, I checked:

1.spi_cs_l goes low during transfer and returns high after completion.
2.Exactly 8 SCLK pulses are generated.
3.MOSI transmits Most Significant Bit (MSB) first.


These are the Errors I Made During RTL Designing.
1. MISO synchronization issue
@(posedge spi_sclk);
miso = data[i];

→ This changes MISO on the same edge where the master samples the data.

The slave should update MISO on the falling edge, so the data is stable before the next rising edge, when the master samples it.

How I solved it,

for(i = 7; i >= 0; i = i - 1) begin
    @(negedge spi_sclk);
    miso = data[i];
end

2. Verification crieterion

Master was sending data correctly:spi_sclk generated correctly

MOSI shifts: check in spi_data

 Shifts correctly: check tx_shift

However, the expected data was not being received on MISO because of a synchronization issue between the master sampling edge and the slave update edge.

3. Counter / shift completion issue
   TX = 0xA5

Expected = 0x3C

Got = 0x1E

assign shift_done = (counter == 3'd7);

else if (shift_en)
    counter <= counter + 1'b1;

As soon as counter became 7, shift_done became 1, and the FSM moved to the CHECK state.

Hence, the counter effectively completed only 7 shifts instead of the required 8 shifts.

=> What This Design Implements
1.SPI Master controller using FSM
2.Shift register-based serial transmission
3.8-bit data transfer
4.Controlled chip select (spi_cs_l)
5.Clock-driven shifting mechanism
 
 =>Tools Used-
Verilog HDL
SystemVerilog Testbench
Icarus Verilog
GTKWave
