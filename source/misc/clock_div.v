/*
 *  Clock Divider
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
 
module clock_div(
clk_sys_i,
rst_n_i,

clk_16hz_o,
clk_8hz_o,
clk_1hz_o,
clk_128hz_o
);

/***************************************************
 Clock Generator Parameters
***************************************************/
parameter FREQ_SYSCLK = 12_000_000;

/***************************************************
 Declaration of IO Ports and Variable
***************************************************/
input clk_sys_i, rst_n_i;
output clk_16hz_o, clk_8hz_o, clk_1hz_o, clk_128hz_o;

reg[24:0] clk_cnt;

/***************************************************
 Clock Generator Functions
***************************************************/
// Pre-dividing counter
always @(posedge clk_sys_i, negedge rst_n_i)
begin
	if(!rst_n_i) begin
		clk_cnt <= 0;
	end
	else begin
		// Generate 16Hz clock
//		if(clk_cnt == (FREQ_SYSCLK / 128 / 2 - 1))
//			clk_cnt <= 0;
//		else
			clk_cnt <= clk_cnt + 1'b1;
	end
end

// Post-dividing counter


/***************************************************
 Wire Connections
***************************************************/
wire clk_16hz_o = clk_cnt[19];  //~11.2Hz
wire clk_8hz_o = clk_cnt[20]; 	//~5.6Hz
wire clk_1hz_o = clk_cnt[23]; 	//~0.7Hz
wire clk_128hz_o = clk_cnt[11];	//~89.6Hz

endmodule
