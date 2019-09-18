package uart_pkg;
    function integer clog2;
    input integer value;
    begin
    value = value-1;
    for (clog2=0; value>0; clog2=clog2+1)
    value = value>>1;
    end
    endfunction
    
    parameter CLK_RATE   = 100_000_000;
    parameter BAUD_RATE  = 19200;
endpackage