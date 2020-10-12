// `include "counter.v"

module pe #(
    parameter integer   FILTER_WIDTH        = 8,
    parameter integer   INPUT_WIDTH         = 8,
    parameter integer   MULT_WIDTH          = FILTER_WIDTH + INPUT_WIDTH,
    parameter integer   PE_OUT_WIDTH        = 24,
    parameter integer   NUM_DATA            = 16
)(
    input   wire                            clk,
    input   wire                            Aload,
    input   wire                            start,
    input   wire                            reset,
    input   wire    [FILTER_WIDTH*NUM_DATA-1:0]   A,
    input   wire    [INPUT_WIDTH    -1:0]   B,
    output  wire    [PE_OUT_WIDTH   -1:0]   Y,
    /*test output*/
    // output  wire    [INPUT_WIDTH    -1:0]   Minput,
    // output  wire    [FILTER_WIDTH   -1:0]   Mfilter,
    // output  wire    [MULT_WIDTH     -1:0]   _mult,
    /*test output end*/
    output  wire                            acc_valid
);
    reg            [FILTER_WIDTH    -1:0]   filter_memory[15:0];
    reg             [INPUT_WIDTH    -1:0]   input_memory;    
    reg             [MULT_WIDTH     -1:0]   mult;
    reg             [PE_OUT_WIDTH   -1:0]   S;
    wire           [$clog2(NUM_DATA)-1:0]   count;  //counter signal
    wire                                    _enable; //counter enable
    reg                                     enable;


    counter#(.NUM_COUNT(NUM_DATA),.COUNTER_WIDTH()) ct(
                .clk(clk),
                .reset(reset),
                .enable(_enable),
                .out(count),
                .vld(acc_valid)
    );
    
    genvar i;
    generate
    for (i=0; i<NUM_DATA; i=i+1)
    begin:filter
        always @(posedge clk)   begin
            if (reset == 1)begin
                filter_memory [i] <= 8'h00;
            end
            else begin
                if (Aload == 1)begin
                    filter_memory [i] <= A[i*FILTER_WIDTH +: FILTER_WIDTH];
                end
                // else begin
                // end
            end
        end
    end
    endgenerate

    always @(posedge clk) begin
        if (reset == 1)begin
            input_memory <= 1'b0;
            mult <= 1'b0;
            S <= 1'b0;
        end
        else begin
            if (start == 1) begin
                input_memory <= B;
            end
            else begin
                enable <= 1'b1;
                input_memory <= B;
                mult <= input_memory * filter_memory[count];
                S <= S + mult;
            end
        end
    end

    // assign _mult = mult;
    // assign Mfilter = filter_memory[count];
    // assign Minput = input_memory;
    assign _enable = enable;
    assign Y = S;

endmodule