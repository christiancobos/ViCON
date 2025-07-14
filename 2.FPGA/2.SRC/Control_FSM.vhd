--------------------------------------------------------------------------------
--  Autor:       Christian Diego Cobos Marcos
--  DNI:         77438323Z
--  Fecha:       16/07/2025
--  Curso:       MSEEI 2024-2025
--  Descripción: ViCON - Control FSM
--------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- 	INSTANCE TEMPLATE  --------------------------------------------------------
-------------------------------------------------------------------------------

--FSM_inst: entity work.Control_FSM
--    port map (
--           -- Control básico
--           CLK => ,
--           RST => ,
           
--           -- Entradas de control de FT245.
--           FIFO_RX_EMPTY => ,
--           FIFO_TX_EMPTY => ,
           
--           -- Salidas de control de FT245.
--           FT245_MODE => 
--    );


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Control_FSM is
    Port ( 
           -- Control básico
           CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           
           -- Entradas de control de FT245.
           FIFO_RX_EMPTY  : in STD_LOGIC;
           FIFO_TX_EMPTY  : in STD_LOGIC;
           
           -- Salidas de control de FT245.
           FT245_MODE     : out STD_LOGIC
           );
end Control_FSM;

architecture Behavioral of Control_FSM is

    -- Tipo y señales de los estados de la FSM
    type STATE is (read_enable, write_enable);
    signal state_reg, state_next: STATE;
    
    -- Señales de las salidas registradas de la FSM
    signal mode_reg, mode_next: STD_LOGIC;

begin

----- State Register -----

process(CLK, RST)
begin

    if RST = '1' then    -- Reset asíncrono
        state_reg <= read_enable;
    elsif CLK'event and CLK = '1' then
        state_reg <= state_next;
        mode_reg <= mode_next;
    end if;

end process;

----- END State Register -----

----- Next State Logic -----

process (state_reg, mode_reg, FIFO_TX_EMPTY)
begin

    -- Asignaciones por defecto para evitar latches.
    state_next <= state_reg;
    
    -- Máquina de estados
    case state_reg is      
        
        when read_enable =>
            mode_next <= '0';
            
            if fifo_tx_empty = '0' then
                state_next <= write_enable;
            end if;
        
        when write_enable =>
            mode_next <= '1';
            
            if fifo_tx_empty = '1' then
                state_next <= read_enable;
            end if;
        
        when others =>
            -- Estado por defecto (no debería ocurrir)
            mode_next <= '0';
            state_next <= read_enable;
        
    end case;

end process;

----- END Next State Logic ----- 

----- Output Logic -----

FT245_MODE <= mode_reg;

----- END Output Logic -----

----- Output Logic -----

FT245_MODE <= mode_reg;

----- END Output Logic -----

end Behavioral;
