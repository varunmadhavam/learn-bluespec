package Testbench;
    import Calc :: *;

    (* synthesize *)
    module mkTestbench (Empty);
        Calc_IFC calc <- mkCalc;
        rule rl_print_val;
            int x = calc.getVal;
            $display ("Deep Thought says: Hello, World! The answer is %0d.", x);
            $finish;
        endrule
    endmodule

endpackage