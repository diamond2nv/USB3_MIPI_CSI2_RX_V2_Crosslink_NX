`timescale 1ns/1ns

module tb_mipi_rx_raw_depacker();
	
		reg clk;
	reg bytes_valid;
	reg  [31:0]bytes_i;
	wire [39:0]bytes_o;
	wire synced;
	reg [2:0]packet_type;
wire reset_g;

GSR 
GSR_INST (
	.GSR_N(1'b1),
	.CLK(1'b0)
);


mipi_rx_raw_depacker ins1(	.clk_i(clk),
						.data_valid_i(bytes_valid),
						.data_i(bytes_i),
						.packet_type_i(packet_type),
						.output_valid_o(synced),
						.output_o(bytes_o));

task sendbytes;
	input [31:0]bytes;
	begin
	bytes_i = bytes;
	clk = 1'b0;
	#4
	clk = 1'b1;
	#4;
	end
endtask

initial begin
		clk = 1'b0;
		bytes_valid = 4'h0;
		packet_type = 3;
		#50
		sendbytes(32'h0);
		sendbytes(32'h0);
		bytes_valid = 1'h1;
		sendbytes(32'h12345678);
		sendbytes(32'h00BCDEF0);
		sendbytes(32'h12005678);
		sendbytes(32'h9ABC00F0);
		sendbytes(32'hBBBBBB00);
		
		sendbytes(32'h12345678);
		sendbytes(32'h00BCDEF0);
		sendbytes(32'h12005678);
		sendbytes(32'h9ABC00F0);
		sendbytes(32'hAAAAAA00);
		
		sendbytes(32'h12345678);
		sendbytes(32'h00BCDEF0);
		sendbytes(32'h12005678);
		sendbytes(32'h9ABC00F0);
		sendbytes(32'hDDDDDD00);		
		bytes_valid = 1'h0;
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		
				packet_type = 4;

		sendbytes(32'h0);
		sendbytes(32'h0);
		bytes_valid = 1'h1;
		sendbytes(32'h12345678);
		sendbytes(32'h00BCDEF0);
		sendbytes(32'h12005678);
		sendbytes(32'h9ABC00F0);
		sendbytes(32'hBBBBBB00);
		
		sendbytes(32'h12345678);
		sendbytes(32'h00BCDEF0);
		sendbytes(32'h12005678);
		sendbytes(32'h9ABC00F0);
		sendbytes(32'hAAAAAA00);
		
		sendbytes(32'h12345678);
		sendbytes(32'h00BCDEF0);
		sendbytes(32'h12005678);
		sendbytes(32'h9ABC00F0);
		sendbytes(32'hDDDDDD00);		
		bytes_valid = 1'h0;
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		
		packet_type = 5;

		sendbytes(32'h0);
		sendbytes(32'h0);
		bytes_valid = 1'h1;
		sendbytes(32'h12345678);
		sendbytes(32'h00BCDEF0);
		sendbytes(32'h12005678);
		sendbytes(32'h9ABC00F0);
		sendbytes(32'hBBBBBB00);
		
		sendbytes(32'h12345678);
		sendbytes(32'h00BCDEF0);
		sendbytes(32'h12005678);
		sendbytes(32'h9ABC00F0);
		sendbytes(32'hAAAAAA00);
		
		sendbytes(32'h12345678);
		sendbytes(32'h00BCDEF0);
		sendbytes(32'h12005678);
		sendbytes(32'h9ABC00F0);
		sendbytes(32'hDDDDDD00);		
		bytes_valid = 1'h0;
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		sendbytes(32'h00000000);
		
		$finish;
end
endmodule