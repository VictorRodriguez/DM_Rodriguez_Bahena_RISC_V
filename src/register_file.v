module register_file(

	 // Entradas
	 input clk,
	 input rst,
    // WD3: 32-bits: Puerto de entrada de datos, donde se coloca el valor
    // a escribir en los registros internos.
	 input  [31:0]  WD3,

    // A1: 5-bits: Dirección de lectura para el puerto RD1. Dependiendo del
    // valor en este puerto, es el registro interno que se entrega por la señal
    // RD1.
    // A2: 5-bits: Dirección de lectura para el puerto RD2. Dependiendo del
    // valor en este puerto, es el registro interno que se entrega por la señal
    // RD1.
    // A3: 5bits: Dirección de escritura a los registros. Dependiendo del valor
    // en este puerto, es al registro que se escribirá con el valor en WD3
    input  [4:0]  A3,
	 input  [4:0]  A1,
	 input  [4:0]  A2,

    // WE 1-bit: Cuando esta señal es igual a 1 lógico habilita la escritura al
    // registro direccionado por la dirección AW.
	 input   WE,

    // Salidas
    // RD1: 32-bits: Puerto de salida en donde se entrega el dato almacenado en
    // el registro direccionado por A1.
    // RD2: 32-bits: Puerto de salida en donde se entrega el dato almacenado en
    // el registro direccionado por A2.
    output [31:0]  RD1,
    output [31:0]  RD2

	);

	reg [31:0] mem [0:31];
	   
	integer i;

  always @(posedge clk, negedge rst) begin
    if (!rst) begin
      for (i=0; i<=31; i=i+1) mem[i] <= {32{1'b0}};
		mem[2] <= 32'b1111111111111111110111111111100;
    end else if (WE && A3 != 0) begin
      mem[A3] <= WD3;
    end
  end
  
  assign RD1 = mem[A1];
  assign RD2 = mem[A2];
  
endmodule
