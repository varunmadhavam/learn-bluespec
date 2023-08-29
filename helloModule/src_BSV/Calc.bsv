package Calc;
    interface Calc_IFC;
        method int getVal;
    endinterface

    (* synthesize *)
    module mkCalc(Calc_IFC);
        method int getVal;
            return 42;
        endmethod
    endmodule
endpackage