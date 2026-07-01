module SPI( 

    input  wire       clk,
    input  wire       rst,
    input  wire       start,

    input  wire [7:0] tx_data,
    input  wire       miso,

    output wire       spi_cs_l,
    output wire       spi_sclk,
    output wire       spi_data,

    output reg [7:0]  rx_data

);


parameter IDLE  = 3'b000;
parameter LOAD  = 3'b001;
parameter SHIFT = 3'b010;
parameter CHECK = 3'b011;
parameter DONE  = 3'b100;

reg [2:0] state;
reg [2:0] next_state;

reg [7:0] tx_shift;
reg [7:0] rx_shift;

   reg [3:0] counter;

reg cs_l;
reg sclk;

wire MOSI;

reg load;
reg shift_en;
reg sample_en;
reg done;

wire shift_done;           parameter CPOL    = 1'b0; 
parameter DIVIDER = 4;

reg [7:0] clk_div_cnt;

reg spi_clk_rise;
reg spi_clk_fall; 



assign spi_cs_l  = cs_l;
assign spi_sclk  = sclk;
assign spi_data  = MOSI;

assign MOSI = tx_shift[7];

   assign shift_done = (counter == 4'd8);

always @(posedge clk or posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        state <= next_state;
end


// Next State Logic

always @(*)
begin

    next_state = state;

    case(state)

        IDLE :
        begin
            if(start)
                next_state = LOAD;
        end

        LOAD :
        begin
            next_state = SHIFT;
        end

      
      SHIFT:
begin
    if(shift_en)
        next_state = CHECK;
    else
        next_state = SHIFT;
end

CHECK :
begin
    if(shift_done)
        next_state = DONE;
    else
        next_state = SHIFT;
end

        DONE :
        begin
            next_state = IDLE;
        end

        default :
            next_state = IDLE;

    endcase

end


// FSM Outputs

always @(*)
 begin 
 load      = 1'b0; 
shift_en  = 1'b0;
sample_en = 1'b0;
done      = 1'b0;
cs_l       = 1'b1; 
 

   
  case(state) 

        IDLE:
        begin
            cs_l = 1'b1;
        end

        LOAD:
        begin
            cs_l = 1'b0;
            load = 1'b1;
        end
 
                 SHIFT: 
begin
    cs_l = 1'b0;

    shift_en  = spi_clk_fall;
    sample_en = spi_clk_rise;
end 

        CHECK:
        begin
            cs_l = 1'b0;
        end

        DONE:
        begin
            cs_l = 1'b1;
            done = 1'b1;
        end

    endcase

end


// TX Shift Register

always @(posedge clk or posedge rst)
begin

    if(rst)
        tx_shift <= 8'b0;

    else if(load)
        tx_shift <= tx_data;

    else if(shift_en)
        tx_shift <= {tx_shift[6:0],1'b0};

end


// RX Shift Register

always @(posedge clk or posedge rst)
begin

    if(rst)
        rx_shift <= 8'b0;

    else if(sample_en)
        rx_shift <= {rx_shift[6:0],miso};

end


// Counter

always @(posedge clk or posedge rst)
begin

    if(rst)
        counter <= 3'b0;

    else if(state == LOAD)
        counter <= 3'b0;

    else if(shift_en)
        counter <= counter + 1'b1;

end


// Received Byte Output

always @(posedge clk or posedge rst)
begin

    if(rst)
        rx_data <= 8'b0;

    else if(state==DONE)
        rx_data <= rx_shift;


end


// Simple SPI Clock

always @(posedge clk or posedge rst)
begin

     if (rst) 
     begin
      clk_div_cnt   <= 0;  
        sclk          <= CPOL;
        spi_clk_rise  <= 1'b0;
        spi_clk_fall  <= 1'b0;
    end

    else
    begin

        spi_clk_rise <= 1'b0;
        spi_clk_fall <= 1'b0;

        if(state == SHIFT)
        begin

            if(clk_div_cnt == DIVIDER-1)
            begin
                clk_div_cnt <= 0;

               if(sclk==CPOL)
begin
    sclk <= ~CPOL;

    spi_clk_rise <= 1'b1;
    spi_clk_fall <= 1'b0;
end
else
begin
    sclk <= CPOL;

    spi_clk_fall <= 1'b1;
    spi_clk_rise <= 1'b0;
end

            end

            else
            begin
                clk_div_cnt <= clk_div_cnt + 1'b1;
            end

        end else
        begin
            clk_div_cnt <= 0;
            sclk <= CPOL;
        end 
    end
end
 endmodule
