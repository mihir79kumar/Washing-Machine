module testbench;
    reg clk, reset;
    reg door_close, start, filled, detergent_added, cycle_timeout, drained, spin_timeout;
    wire door_lock, motor_on, fill_value_on, drain_value_on, done, soap_wash, water_wash;

    automatic_washing_machine uut (
        .clk(clk), .reset(reset), .door_close(door_close), .start(start),
        .filled(filled), .detergent_added(detergent_added),
        .cycle_timeout(cycle_timeout), .drained(drained), .spin_timeout(spin_timeout),
        .door_lock(door_lock), .motor_on(motor_on), .fill_value_on(fill_value_on),
        .drain_value_on(drain_value_on), .done(done), .soap_wash(soap_wash), .water_wash(water_wash)
    );

    initial begin
        // Dump waveform
        $dumpfile("washing_machine.vcd");
        $dumpvars(0, testbench);

        // Initialize
        clk = 0;
        reset = 1;
        start = 0; door_close = 0; filled = 0; detergent_added = 0;
        cycle_timeout = 0; drained = 0; spin_timeout = 0;

        #10 reset = 0;           // Deassert reset
        #10 start = 1; door_close = 1;

        #20 filled = 1;          // Water filled
        #20 detergent_added = 1; // Detergent added
        #30 cycle_timeout = 1;   // Cycle ends
        #20 drained = 1;         // Drain complete
        #30 spin_timeout = 1;    // Spin complete

        #100 $finish;
    end

    always #5 clk = ~clk; // 10ns clock period

    initial begin
        $monitor("Time=%0t | State: door_lock=%b, motor_on=%b, fill_valve=%b, drain_valve=%b, soap=%b, water=%b, done=%b",
            $time, door_lock, motor_on, fill_value_on, drain_value_on, soap_wash, water_wash, done);
    end
endmodule