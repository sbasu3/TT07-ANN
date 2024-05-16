`include "qmults.v"
`include "qadd.v"

// WIDTH = 16 CLKs for one multiplication
module mac #(parameter WIDTH = 16) (
    input wire signed [WIDTH-1:0] a,        //Input for X
    input wire signed [WIDTH-1:0] b,        //Input for Theta
    input wire clk,                         //Clock
    input wire mac_clk,                     //MAC Clock : Variables changed on input
    input wire reset,                       //Reset
    output reg signed [WIDTH-1:0] acc,      //Output
    output reg ready                        //Output ready
);
parameter LOG_WIDTH = $clog2(WIDTH);

reg signed [WIDTH-1:0] result;
wire signed [WIDTH-1:0] temp_acc;
wire start;
wire done;
wire overflow;

reg [LOG_WIDTH]clk_count;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        clk_count <= 0;
    end else begin
        if (clk_count == WIDTH-1) begin
            clk_count <= 0;
        end else begin
            clk_count <= clk_count + 1;
        end
    end
end


always @(posedge mac_clk or posedge reset) begin
    if (reset) begin
        acc <= 0;
        temp_acc <= 0;
        result <= 0;
        start <= 0;
    end else begin
        acc <= temp_acc;
        start<=1'b1;
    end
end

always@(negedge mac_clk) begin
    start <= 1'b0;
end

qmults #(.Q(WIDTH/2),.N(WIDTH)) qmults_inst (
    .i_multiplicand(a),
    .i_multiplier(b),
    .i_start(start),
    .i_clk(clk),
    .o_result_out(result),
    .o_complete(done),
    .o_overflow(overflow)
);

qadd #(.Q(WIDTH/2),.N(WIDTH)) qadd_inst (
    .a(acc),
    .b(result),
    .c(temp_acc)
);

always @(posedge done and posedge clk) begin
    if(clk_count == WIDTH-1) begin
        acc <= temp_acc;
    end
end

always @(posedge clk or posedge reset) begin
    if (clk_count == WIDTH-1) begin
        ready <= 1'b1;
    end else begin
        ready <= 0;
    end
end

endmodule



