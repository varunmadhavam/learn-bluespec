// Top-level for sequence detector
// The sequence detector is assumed to be in the package SeqDet
// 
//
import FIFOF :: *;
import Utils :: *;          // for cur_cycle and friends
import SeqDet:: *;          // the design
import SeqDetTypes :: *;    // all type defs reside here
import Mem :: *;            // for the memory
import Connectable :: *;
import ClientServer :: *;
import GetPut::*;

(* synthesize *)
module mkTestbench (Empty);

        Reg #(Bit#(4)) r_numreq <- mkReg (0);
        Reg #(Bit#(4)) r_numrsp <- mkReg (0);
        Reg #(Bit#(Addr_Width)) addr <- mkReg (0);
        FIFOF #(MAddr) f_mreq <- mkFIFOF;
        FIFOF #(MData) f_mrsp <- mkFIFOF;
        Mem_IFC mem <- mkMem;

        rule rl_mem_req (r_numreq < 8);
                mem.request.put(addr);   // implicit condition here!
                r_numreq <= r_numreq + 1;
                addr     <= addr + 1;
                $display ("(%05d) rl_req::", cur_cycle, fshow (addr));
        endrule

        rule rl_mem_rsp (r_numrsp < 8);
                r_numrsp <= r_numrsp + 1;
                let r = mem.response.get(); // implicit condition here!
                $display ("(%05d)           rl_rsp:: %H", cur_cycle,r);
                if (r_numrsp == 7) $finish();
        endrule
endmodule
