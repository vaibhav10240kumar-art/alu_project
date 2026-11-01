module alu #(parameter N = 8)(
input [N-1:0] a, b,
input [3:0] op,
output reg [N-1:0] y,
output reg carry,
output reg overflow,
output zero,
output negative
);
reg [N:0] tmp;

always @(*) begin
//defaults prevents accidental latches
tmp = 0; y = 0; carry = 0; overflow = 0;

case (op)
4'b0000: begin  //ADD 
tmp = {1'b0, a} + {1'b0, b};
y = tmp[N-1:0];
carry = tmp[N];
overflow = (a[N-1] == b[N-1]) && (y[N-1] != a[N-1]);
end 

4'b0001: begin  //SUB
tmp = {1'b0, a} - {1'b0, b};
y = tmp[N-1:0];
carry = tmp[N];
overflow = (a[N-1] != b[N-1]) && (y[N-1] != a[N-1]);
end 

4'b0010: y = a & b; 
4'b0011: y = a | b;
4'b0100: y = a ^ b;
4'b0101: y = ~a;
4'b0110: y = a << b[$clog2(N)-1:0];
4'b0111: y = a >> b[$clog2(N)-1:0]; 
4'b1000: y = $signed(a) >>> b[$clog2(N)-1:0]; 
4'b1001: y = ($signed(a) < $signed(b)) ? 1 : 0;
default: y = 0;
endcase 
end

assign zero = (y == 0);
assign negative = y[N-1];
endmodule










