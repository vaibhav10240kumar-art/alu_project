`timescale 1ns/1ps
module alu_tb;
parameter N = 8;
reg [N-1:0] a, b;
reg [3:0] op;
wire [N-1:0] y;
wire carry, overflow, zero, negative;

alu #(N) dut (.a(a), .b(b), .op(op), .y(y),
 .carry(carry), .overflow(overflow),
 .zero(zero), .negative(negative));

integer errors = 0;
 task check(input [N-1:0] exp_y, input [255:0] name);
begin
#1;
if (y!==exp_y) begin
$display("FAIL %0s: a=%0d b=%0d got=%0d exp=%0d", name, a, b, y, exp_y);

errors = errors + 1;
end else
$display("PASS %0s: %0d, %0d -> %0d", name, a, b, y);
end 
endtask

initial begin
$dumpfile("alu.vcd");
$dumpvars(0, alu_tb);

a = 8'd10;  b = 8'd5;   op = 4'b0000; check(8'd15, "ADD");
a = 8'd200; b = 8'd100; op = 4'b0000; check(8'd44, "ADD wrap");
if (!carry) begin $display("FAIL carry"); errors = errors + 1; end
a = 8'd10;  b = 8'd5;   op = 4'b0001; check(8'd5,  "SUB");
a = 8'd5;   b = 8'd5;   op = 4'b0001; check(8'd0,  "SUB zero");
if (!zero) begin $display("FAIL zero flag"); errors = errors + 1; end
a = 8'hF0;  b = 8'h3C;  op = 4'b0010; check(8'h30, "AND");
a = 8'hF0;  b = 8'h0F;  op = 4'b0011; check(8'hFF, "OR");
a = 8'hFF;  b = 8'h0F;  op = 4'b0100; check(8'hF0, "XOR");
a = 8'h0F;              op = 4'b0101; check(8'hF0, "NOT");
a = 8'd3;   b = 8'd2;   op = 4'b0110; check(8'd12, "SLL");
a = 8'd12;  b = 8'd2;   op = 4'b0111; check(8'd3,  "SRL");
a = 8'hF0;  b = 8'd2;   op = 4'b1000; check(8'hFC, "SRA");
a = 8'hFB;  b = 8'd3;   op = 4'b1001; check(8'd1,  "SLT");  // -5 < 3

if (errors == 0) $display("ALL TESTS PASSED");
else $display("%0d TEST FAILED", errors);
$finish;

end 
endmodule

