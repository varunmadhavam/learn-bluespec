package Calc;
    interface Calc_IFC;
        method Action start;
        method ActionValue#(int) get;
    endinterface

    typedef enum { IDLE, THINKING, ANSWER_READY } State_DT deriving (Eq, Bits, FShow);

    (* synthesize *)
    module mkCalc(Calc_IFC);
        Reg#(State_DT) state <- mkReg(IDLE);
        Reg#(Bit#(4)) count <- mkReg(0);

        rule rl_thinking ( state == THINKING );
            $display ("Thinking.....!!!)");
            if(count == 15)
                state <= ANSWER_READY;
            else
                count <= count + 1;
        endrule

        method Action start if( state == IDLE);
            state <= THINKING;
        endmethod

        method ActionValue#(int) get if( state == ANSWER_READY);
            state <= IDLE;
            count <= 0;
            return 42;
        endmethod
    endmodule
endpackage