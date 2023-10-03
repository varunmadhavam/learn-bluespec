// A place holder for the sequence detector to satisfy compilation.
// Doesn't do anything.
package SeqDet;
        import SeqDetTypes :: *;
        import FIFOF :: *;
        import ClientServer :: *;
        import GetPut :: *;
        module mkSeqDet (SeqDetIfc);
                FIFOF #(MAddr) f_mreq         <- mkFIFOF;
                FIFOF #(MData) f_mrsp         <- mkFIFOF;
                Reg #(RspType) r_rsp          <- mkReg (tagged Invalid);

                Reg#(Bit#(1))  r_busy         <- mkReg(0);
                Reg#(Bit#(4))  r_num_words    <- mkReg(0);
                Reg#(Bit#(8))  r_pattern      <- mkReg(0);
                Reg#(Bit#(8))  r_shf_pat      <- mkReg(0);
                Reg#(Bit#(9))  r_shf_cnt      <- mkReg(0);
                Reg#(MAddr)    r_mem_addr     <- mkReg(0);
                Reg#(MemWord)  r_memword      <- mkReg(tagged Invalid);
                Reg#(Bit#(4))  r_req_word_cnt <- mkReg(0);
                Reg#(Bit#(4))  r_res_word_cnt <- mkReg(0);
                Reg#(MData)    x              <- mkReg(0);
                Reg#(Bit#(16)) r_pat_cnt      <- mkReg(0);

                rule mem_access_req( (r_busy == 1) && (r_req_word_cnt < r_num_words) );
                        f_mreq.enq(r_mem_addr);
                        r_mem_addr <= r_mem_addr + 1;
                        r_req_word_cnt <= r_req_word_cnt + 1;
                endrule

                rule mem_access_resp ( (r_busy == 1) && (r_res_word_cnt < r_num_words) && (r_memword == tagged Invalid));
                        let memword = f_mrsp.first;
                        f_mrsp.deq;
                        r_memword <= tagged Valid memword;
                        r_shf_cnt <= 0;
                        r_res_word_cnt <= r_res_word_cnt + 1;
                endrule

                rule match_pattern ( (r_busy == 1) && (r_shf_cnt <= 256) && isValid(r_memword));
                        if( r_memword matches tagged Valid .x )
                                begin
                                        if( r_shf_cnt < 256)
                                                begin
                                                        r_shf_pat <= (r_shf_pat<<1) | extend(x[255]);
                                                        r_memword <= tagged Valid (x << 1);
                                                end
                                        else
                                                r_memword <= tagged Invalid;

                                        if(r_shf_pat == r_pattern)
                                                r_pat_cnt <= r_pat_cnt + 1;

                                        r_shf_cnt <= r_shf_cnt + 1;
                                end
                endrule

                rule  set_result( (r_busy == 1) && (r_rsp == tagged Invalid) && (r_res_word_cnt == r_num_words) && r_shf_cnt == 257);
                        r_rsp <= tagged Valid r_pat_cnt;
                endrule

                method Action request (ReqType req) if ( r_busy == 0 );
                        r_busy           <= 1;
                        r_num_words      <= req.words;
                        r_pattern        <= req.pattern;
                        r_mem_addr       <= req.addr;
                        $display ("data = %x",req.addr);
                        r_req_word_cnt   <= 0;
                        r_res_word_cnt   <= 0;
                        x                <= 0;
                        r_rsp            <= tagged Invalid;
                        r_pat_cnt        <= 0;
                        r_shf_pat        <= 0;
                endmethod

                method ActionValue #(RspType) response if ( (r_busy == 1) && isValid(r_rsp) );
                        r_busy  <= 0;
                        r_rsp   <= tagged Invalid;
                        return (r_rsp);
                endmethod 

                interface mem = toGPClient (f_mreq, f_mrsp);
        endmodule
endpackage
