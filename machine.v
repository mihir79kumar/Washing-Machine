
module automatic_washing_machine(
    input clk, reset, door_close, start, filled, detergent_added, cycle_timeout, drained, spin_timeout,
    output reg door_lock, motor_on, fill_value_on, drain_value_on, done, soap_wash, water_wash
);

    parameter check_door = 3'b000,
              fill_water = 3'b001,
              add_detergent = 3'b010,
              cycle = 3'b011,
              drain_water = 3'b100,
              spin = 3'b101;

    reg [2:0] current_state, next_state;

    always @(current_state or start or door_close or filled or detergent_added or drained or cycle_timeout or spin_timeout or soap_wash or water_wash) begin
        case(current_state)
            check_door: begin
                if(start && door_close) begin
                    next_state = fill_water;
                    door_lock = 1;
                end else begin
                    next_state = check_door;
                    door_lock = 0;
                end
                motor_on = 0; fill_value_on = 0; drain_value_on = 0;
                soap_wash = 0; water_wash = 0; done = 0;
            end

            fill_water: begin
                if(filled) begin
                    if(soap_wash == 0) begin
                        next_state = add_detergent;
                        soap_wash = 1; water_wash = 0;
                    end else begin
                        next_state = cycle;
                        soap_wash = 1; water_wash = 1;
                    end
                    fill_value_on = 0;
                end else begin
                    next_state = fill_water;
                    fill_value_on = 1;
                end
                motor_on = 0; drain_value_on = 0; door_lock = 1; done = 0;
            end

            add_detergent: begin
                if(detergent_added) begin
                    next_state = cycle;
                end else begin
                    next_state = add_detergent;
                end
                motor_on = 0; fill_value_on = 0; drain_value_on = 0;
                door_lock = 1; soap_wash = 1; water_wash = 0; done = 0;
            end

            cycle: begin
                if(cycle_timeout) begin
                    next_state = drain_water;
                    motor_on = 0;
                end else begin
                    next_state = cycle;
                    motor_on = 1;
                end
                fill_value_on = 0; drain_value_on = 0;
                door_lock = 1; done = 0;
            end

            drain_water: begin
                if(drained) begin
                    if(water_wash == 0)
                        next_state = fill_water;
                    else
                        next_state = spin;
                end else begin
                    next_state = drain_water;
                    drain_value_on = 1;
                end
                motor_on = 0; fill_value_on = 0;
                door_lock = 1; soap_wash = 1; done = 0;
            end

            spin: begin
                if(spin_timeout) begin
                    next_state = check_door;
                    done = 1;
                end else begin
                    next_state = spin;
                    done = 0;
                end
                motor_on = 0; fill_value_on = 0; drain_value_on = 0;
                door_lock = 1; soap_wash = 1; water_wash = 1;
            end

            default: begin
                next_state = check_door;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if(reset)
            current_state <= check_door;
        else
            current_state <= next_state;
    end

endmodule

