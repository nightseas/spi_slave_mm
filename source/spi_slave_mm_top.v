/*
 *  Top Entry of SPI Slave to Memory Mapped Bus Master Reference Design
 *
 *  Copyright (C) 2018, Xiaohai Li (haixiaolee@gmail.com), All Rights Reserved
 *  This program is lincensed under Apache-2.0/GPLv3 dual-license
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  Apache-2.0 License and GNU General Public License for more details.
 *
 *  You may obtain a copy of Apache-2.0 License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 * 
 *  And GPLv3 License at
 *
 *  http://www.gnu.org/licenses
 *
 */

module spi_slave_mm_top(
//// For simulation only
//spi_main_fsm,
//spi_addr_cnt,
//spi_wdata_cnt,
//spi_rdata_cnt,
//spi_addr_buf,
//spi_wdata_buf,
//sys_clk_dbg,

// Global Clock and Reset
ext_clk,
rst_n,

// SPI Slave Interface
spi_sclk,
spi_mosi,
spi_miso,
spi_cs_n,

// LED Control Signals
led_ctrl,
led_debug,

// Interrupt Signals
int_ext,
int_sys,

// Bootstrap Signals
pid_strap
);

/***************************************************
 Public Parameters
***************************************************/
parameter MM_ADDR_WIDTH = 8;
parameter MM_DATA_WIDTH = 16;


/***************************************************
 Declaration of IO Ports, Variable, Wire Connection
***************************************************/
//---------- Global Clock and Reset -----------
input ext_clk, rst_n;

//---------- SPI Slave Interface -----------
input spi_sclk, spi_mosi, spi_cs_n;
output spi_miso;

//---------- Bootstrap Signals -----------
input[3:0] pid_strap;

//---------- LED Control Signals -----------
output[3:0] led_ctrl, led_debug;

input[2:0] int_ext;
output int_sys;

////---------- For Simulation Only -----------
//output[4:0] spi_addr_cnt;
//output[5:0] spi_wdata_cnt, spi_rdata_cnt;
//output[5:0] spi_main_fsm;
//output[MM_ADDR_WIDTH-1:0] spi_addr_buf;
//output[MM_DATA_WIDTH-1:0] spi_wdata_buf;
//output sys_clk_dbg;


//---------- Internal Registers & Wires -----------
// MM Master Interface
wire[MM_ADDR_WIDTH-1:0] m_addr;
wire[MM_DATA_WIDTH-1:0] m_wdata;
wire[MM_DATA_WIDTH-1:0] m_rdata;
wire m_we;
// MM Slave Interface
wire[MM_ADDR_WIDTH-1:0] s_addr;
wire[MM_DATA_WIDTH-1:0] s_wdata;
wire[MM_DATA_WIDTH-1:0] s_rdata0, s_rdata1, s_rdata2, s_rdata3, s_rdata4;
wire s_we;

reg[1:0] sync_rst;

wire clk_16hz, clk_8hz, clk_1hz, clk_128hz;
wire[3:0] led_ctrl, led_debug;
wire wdt_ot;

//wire sys_rst_n, sys_clk;

//// Debug
//wire[4:0] spi_addr_cnt;
//wire[5:0] spi_wdata_cnt, spi_rdata_cnt;
//wire[5:0] spi_main_fsm;
//wire[MM_ADDR_WIDTH-1:0] spi_addr_buf;
//wire[MM_DATA_WIDTH-1:0] spi_wdata_buf;

/***************************************************
 Public Sync Functions
***************************************************/
always @(posedge ext_clk)
begin
	sync_rst[0] <= rst_n;
	sync_rst[1] <= sync_rst[0];
end

/***************************************************
 Call of Modules & Interconnections
***************************************************/
spi_slave #(.MM_ADDR_WIDTH(MM_ADDR_WIDTH), .MM_DATA_WIDTH(MM_DATA_WIDTH)) spi_slave_inst(
//	// For simulation only
//	.spi_main_fsm(spi_main_fsm),
//	.spi_addr_cnt(spi_addr_cnt),
//	.spi_wdata_cnt(spi_wdata_cnt),
//	.spi_rdata_cnt(spi_rdata_cnt),
//	.spi_addr_buf(spi_addr_buf),
//	.spi_wdata_buf(spi_wdata_buf),

	
	.clk_sys_i(ext_clk),
	.rst_n_i(sync_rst[1]),

	.spi_sclk_i(spi_sclk),
	.spi_mosi_i(spi_mosi),
	.spi_miso_o(spi_miso),
	.spi_cs_n_i(spi_cs_n),
	
	.mm_m_addr_o(m_addr),
	.mm_m_wdata_o(m_wdata),
	.mm_m_rdata_i(m_rdata),
	.mm_m_we_o(m_we)
	);

mm_con #(.MM_ADDR_WIDTH(MM_ADDR_WIDTH), .MM_DATA_WIDTH(MM_DATA_WIDTH)) mm_con_inst(
	.clk_sys_i(ext_clk),
	.rst_n_i(sync_rst[1]),
	
	.m_addr_i(m_addr),
	.m_wdata_i(m_wdata),
	.m_rdata_o(m_rdata),
	.m_we_i(m_we),
	
	.s_addr_o(s_addr),
	.s_wdata_o(s_wdata),
	.s_rdata0_i(s_rdata0),
	.s_rdata1_i(s_rdata1),
	.s_rdata2_i(s_rdata2),
	.s_rdata3_i(s_rdata3),
	.s_rdata4_i(s_rdata4),
	.s_we_o(s_we)
	);

product_test #(.MM_ADDR_WIDTH(MM_ADDR_WIDTH), .MM_DATA_WIDTH(MM_DATA_WIDTH)) product_test_inst(
	.clk_sys_i(ext_clk),
	.rst_n_i(sync_rst[1]),
	
	.mm_s_addr_i(s_addr),
	.mm_s_wdata_i(s_wdata),
	.mm_s_rdata_o(s_rdata0),
	.mm_s_we_i(s_we),
	
	.pid_strap_i(pid_strap)
	);	
	
int_ctrl #(.MM_ADDR_WIDTH(MM_ADDR_WIDTH), .MM_DATA_WIDTH(MM_DATA_WIDTH)) int_ctrl_inst(
	.clk_sys_i(ext_clk),
	.rst_n_i(sync_rst[1]),

	.mm_s_addr_i(s_addr),
	.mm_s_wdata_i(s_wdata),
	.mm_s_rdata_o(s_rdata1),
	.mm_s_we_i(s_we),

	.int_a_i(int_ext[0]), 
	.int_b_i(int_ext[1]), 
	.int_c_i(int_ext[2]), 
	.int_wdt_i(wdt_ot),
	.sys_int_o(int_sys)
);

sys_wdt #(.MM_ADDR_WIDTH(MM_ADDR_WIDTH), .MM_DATA_WIDTH(MM_DATA_WIDTH)) sys_wdt_inst(
	.clk_sys_i(ext_clk),
	.rst_n_i(sync_rst[1]),

	.mm_s_addr_i(s_addr),
	.mm_s_wdata_i(s_wdata),
	.mm_s_rdata_o(s_rdata2),
	.mm_s_we_i(s_we),

	.clk_8hz_i(clk_8hz),
	.wdt_ot_o(wdt_ot)
);

led_ctrl #(.MM_ADDR_WIDTH(MM_ADDR_WIDTH), .MM_DATA_WIDTH(MM_DATA_WIDTH)) led_ctrl_inst(
	.clk_sys_i(ext_clk),
	.rst_n_i(sync_rst[1]),

	.mm_s_addr_i(s_addr),
	.mm_s_wdata_i(s_wdata),
	.mm_s_rdata_o(s_rdata3),
	.mm_s_we_i(s_we),

	.clk_16hz_i(clk_16hz),
	.clk_8hz_i(clk_8hz),
	.clk_1hz_i(clk_1hz),

	.led_ctrl_o(led_ctrl),
	.led_debug_o(led_debug)
);
	
clock_div clock_div_inst(
	.clk_sys_i(ext_clk),
	.rst_n_i(sync_rst[1]),
	
	.clk_16hz_o(clk_16hz),
	.clk_8hz_o(clk_8hz),
	.clk_1hz_o(clk_1hz),
	.clk_128hz_o(clk_128hz)
	);	
	
//max10_pll	max10_pll_inst (
//	.areset ( ~rst_n ),
//	.inclk0 ( ext_clk ),
//	.c0 ( sys_clk ),
//	.locked ( sys_rst_n )
//	);

/***************************************************
 Wire and Open-Drain Connections
***************************************************/
//// For simulation only
//assign sys_clk_dbg = sys_clk;
//assign sys_clk = ext_clk;
//assign sys_rst_n = sync_rst[1];

endmodule
