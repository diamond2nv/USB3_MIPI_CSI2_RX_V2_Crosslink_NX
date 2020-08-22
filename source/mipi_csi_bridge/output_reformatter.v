`timescale 1ns/1ns

/*
MIPI CSI RX to Parallel Bridge (c) by Gaurav Singh www.CircuitValley.com

MIPI CSI RX to Parallel Bridge is licensed under a
Creative Commons Attribution 3.0 Unported License.

You should have received a copy of the license along with this
work.  If not, see <http://creativecommons.org/licenses/by/3.0/>.
*/

/*
Takes 64bit 4pixel yuv input from rgb2yuv module @ mipi byte clock outputs 32bit 2pixel yuv output @output_clk_i , 
output_clk_i must be generated by same way as mipi byte clock, output_clk_i must be exactly double to mipi byteclock
This implementation of Output reformatter outputs data which which meant to send out of the system to a 32bit receiver 
depending on requirement this will be need to be adapted as per the receiver 
*/

module output_reformatter(
						  clk_i, //data changes on negedge 
						  output_clk_i, //output clock double to clk_i to get in 64bit and output 32bit
						  data_i,
						  data_in_valid_i,
						  line_sync_i,
						  output_o,
						  output_valid_o,
						  frame_sync_i
						  );
						  
input line_sync_i;
input frame_sync_i;
input clk_i;
input data_in_valid_i;
input [63:0]data_i;
output reg output_valid_o;
output [31:0]output_o;
input output_clk_i;


reg [10:0] write_address;
reg [11:0] read_address;


wire [31:0]ram_even_o;
wire [31:0]ram_odd_o;

reg [10:0] input_pixel_count;
reg line_even_nodd;				//select between two different RAM
reg last_line_sync;				//helps to determine edge of line sync for write address reset
reg last_line_even_nodd;		//helps to determine edge of line sync for read address reset
 

out_line_ram_dp line_odd(	.wr_clk_i(!clk_i), 
							.rd_clk_i(output_clk_i), 
							.rst_i(!frame_sync_i), 
							.wr_clk_en_i(data_in_valid_i),
							.rd_en_i(line_even_nodd), 
							.rd_clk_en_i(1'b1), 
							.wr_en_i(!line_even_nodd), 
							.wr_data_i({data_i[31:0], data_i[63:32]}), 
							.wr_addr_i(write_address), 
							.rd_addr_i(read_address), 
							.rd_data_o(ram_odd_o));


out_line_ram_dp line_even(	.wr_clk_i(!clk_i), 
							.rd_clk_i(output_clk_i), 
							.rst_i(!frame_sync_i), 
							.wr_clk_en_i(data_in_valid_i), 
							.rd_en_i(!line_even_nodd), 
							.rd_clk_en_i(1'b1), 
							.wr_en_i(line_even_nodd), 
							.wr_data_i({data_i[31:0], data_i[63:32]}), 
							.wr_addr_i(write_address), 
							.rd_addr_i(read_address), 
							.rd_data_o(ram_even_o)); 

/*
out_line_ram_ldp line_odd(	.clk_i((line_even_nodd)?!clk_i:output_clk_i), 
							.dps_i(1'b1), 
							.rst_i(!frame_sync_i), 
							.wr_clk_en_i(data_in_valid_i), 
							.rd_clk_en_i(!line_even_nodd), 
							.wr_en_i(line_even_nodd), 
							.wr_data_i(data_i), 
							.wr_addr_i(write_address), 
							.rd_addr_i(read_address), 
							.rd_data_o(ram_even_o), 
							.lramready_o(), 
							.rd_datavalid_o());
							
out_line_ram_ldp line_even(	.clk_i((!line_even_nodd)?!clk_i:output_clk_i), 
							.dps_i(1'b1), 
							.rst_i(!frame_sync_i), 
							.wr_clk_en_i(data_in_valid_i), 
							.rd_clk_en_i(line_even_nodd), 
							.wr_en_i(!line_even_nodd), 
							.wr_data_i(data_i), 
							.wr_addr_i(write_address), 
							.rd_addr_i(read_address), 
							.rd_data_o(ram_odd_o), 
							.lramready_o(), 
							.rd_datavalid_o()) ;
*/
//assign output_o = line_even_nodd? ram_odd_o[((read_address[0])?6'd32:6'd0) +:32]: ram_even_o[((read_address[0])?6'd32:6'd0) +:32]; //depeding on line select even or odd ram , also select correct 32bit word from 64 bit ramoutput

assign output_o = line_even_nodd? ram_odd_o:ram_even_o; //depeding on line select even or odd ram 

always @(posedge line_sync_i or negedge frame_sync_i)
begin
	if (!frame_sync_i)
	begin
		line_even_nodd <= 0;
	end
	else
	begin
		line_even_nodd <= !line_even_nodd;
	end
end	


always @(negedge clk_i )
begin
	
	last_line_sync <= line_sync_i;
	if (!last_line_sync && line_sync_i)
	begin
		write_address <= 9'b0;
		input_pixel_count <= write_address << 1 ; //Double write_address as each write_address has 64 bit while output width is 32bit
	end
	else
	begin
		write_address <= write_address + data_in_valid_i; 
	end
end


always @(posedge output_clk_i)
begin
		last_line_even_nodd <= line_even_nodd;
		
		if ( last_line_even_nodd != line_even_nodd)	//reset read address for each new line
		begin
			 read_address <= 12'b0;
			 output_valid_o <= 1'b0;
		end
		else
			begin
			if (read_address < input_pixel_count)
			begin
				read_address <= read_address + 1'b1;
				output_valid_o <= 1'b1;
			end
			else
			begin
				output_valid_o <= 1'b0;
			end 
		end
end


endmodule