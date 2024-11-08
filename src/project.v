
module tt_um_VanceWiberg_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // All output pins must be assigned. If not used, assign to 0.

    wire eco; //End of Conversation

  sar_adc mySAR 
    (
    .clk_i(clk),
    .start_i(ui_in[1]),
    .rst_ni(rst_n),
    .comp_i(ui_in[0]),
    .rdy_o(eco),
    .dac_o(uo_out)
    );

    assign uio_oe [7:1] = 0;
    assign uio_oe [0] = 1'b1;
    assign uio_out [7:1] = 0;
    assign uio_out [0] = eco;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_out[7:1], uio_oe[7:1]};

endmodule

//////////////////////////////////////////////////////////
// Module Below is borrowed from Cedric Hirschi
// https://github.com/CedricHirschi/fpga-sar/blob/main/verilog/main.v 

module sar_adc (
    input wire clk_i,                 // Clock input
    input wire start_i,               // Start conversion signal
    input wire rst_ni,               // Asynchronous reset
    input wire comp_i,      // Input from external analog comparator
    output wire rdy_o,              // Conversion complete signal
    output wire [7:0] dac_o      // Output to external R-2R ladder DAC
);

    // State definitions
    localparam IDLE = 0;
    localparam CONVERT = 1;
    localparam DONE = 2;

    // Internal signals
    reg [2:0] state_q, state_d; // State registers
    reg [7:0] mask_q, mask_d; // Mask for conversion
    reg [7:0] result_q, result_d; // Result of conversion

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_q <= IDLE;
            mask_q <= 1 << (7);
            result_q <= 0;
        end else begin
            state_q <= state_d;
            mask_q <= mask_d;
            result_q <= result_d;
        end
    end

    // SAR Conversion Logic
    always @(*) begin

        case (state_q)
            IDLE: begin
                
                if (start_i) begin
                    state_d = CONVERT;
                    mask_d = 1 << (7);
                    result_d = 0;
                end else begin
                    state_d = IDLE;
                    mask_d = mask_q;
                    result_d = result_q;
                end
                
            end

            CONVERT: begin

                if (comp_i) begin
                    mask_d = mask_q >> 1;
                    result_d = result_q | mask_q;
                end else begin
                    mask_d = mask_q >> 1;
                    result_d = result_q;
                end

                if (mask_d == 0) begin
                    state_d = DONE;
                end else begin
                    state_d = CONVERT;
                end
                
            end
                
            DONE: begin

                state_d = IDLE;
                mask_d = mask_q;
                result_d = result_q;
             
            end

            default: begin
                
                state_d = IDLE;
                mask_d = mask_q;
                result_d = result_q;
                
            end

        endcase
    end

    assign dac_o = result_q | mask_q;
    assign rdy_o = (state_q == DONE);

endmodule

/////////////////////////////////////////////////////////////

