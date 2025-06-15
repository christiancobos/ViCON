----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.06.2025 15:45:05
-- Design Name: 
-- Module Name: FT245_control - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FT245_control is
    Port ( 
           CLK           : in STD_LOGIC;
           RST           : in STD_LOGIC;
           fifo_rx_full  : in STD_LOGIC;
           fifo_tx_empty : in STD_LOGIC;
           RDn           : in STD_LOGIC;
           WRn           : in STD_LOGIC;
           rd_en         : out STD_LOGIC;
           wr_en         : out STD_LOGIC
           );
end FT245_control;

architecture Behavioral of FT245_control is

    -- Tipo y señales de los estados de la FSM
    type STATE is (idle, read_enable, write_enable);
    signal state_reg, state_next: STATE;
    
    -- Señales de las salidas registradas de la FSM
    signal rd_en_reg, rd_en_next: STD_LOGIC;
    signal wr_en_reg, wr_en_next: STD_LOGIC;

begin

----- State Register -----

process(CLK, RST)
begin

    if RST = '1' then    -- Reset asíncrono
        state_reg <= idle;
    elsif CLK'event and CLK = '1' then
        state_reg <= state_next;
        rd_en_reg <= rd_en_next;
        wr_en_reg <= wr_en_next;
    end if;

end process;

----- END State Register -----

----- Next State Logic -----

process (state_reg, rd_en_reg, wr_en_reg)
begin

    -- Asignaciones por defecto para evitar latches.
    state_next <= state_reg;
    
    -- Máquina de estados
    case state_reg is
    
        when idle =>
            rd_en_next <= '0';
            wr_en_next <= '0';
            
            if fifo_tx_empty = '0' then
                state_next <= write_enable;
            elsif fifo_rx_full = '0' then
                state_next <= read_enable;
            end if;
        
        
        when read_enable =>
            rd_en_next <= '1';
            wr_en_next <= '0';
            
            if fifo_tx_empty = '0' and RDn = '1' then
                state_next <= write_enable;
            elsif fifo_rx_full = '1' and RDn = '1' then
                state_next <= idle;
            end if;
        
        when write_enable =>
            rd_en_next <= '0';
            wr_en_next <= '1';
            
            if fifo_tx_empty = '1' then
                if fifo_rx_full = '1' then
                    state_next <= idle;
                else
                    state_next <= read_enable;
                end if;
            end if;
        
        when others =>
            -- Estado por defecto (no debería ocurrir)
            rd_en_next <= '0';
            wr_en_next <= '0';
            state_next <= idle;
        
    end case;

end process;

----- END Next State Logic -----

----- Conexión de señales con salidas -----



----- END Conexión de señales con salidas -----
    

end Behavioral;
