package Testbench;
    import Calc :: *;

    (* synthesize *)
    module mkTestbench (Empty);
        Calc_IFC calc <- mkCalc;
        Reg#(Bit#(4)) count <- mkReg(0);

        rule rl_start;
            $display ("Starting to THINK...!!!!!");
            calc.start;
        endrule

        rule rl_print_val;
            int x <- calc.get;
            $display ("Deep Thought says: Hello, World! The answer is %0d.", x);
            if( count == 10)
                $finish;
            else
                count <= count + 1;
        endrule
    endmodule

endpackage