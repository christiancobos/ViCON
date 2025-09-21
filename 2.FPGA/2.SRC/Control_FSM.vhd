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
--           FIFO_RX_VALUE => ,

--           -- Entradas de control de cámara
--           FRAME_END     => ,
           
--           -- Salidas de control de FT245.
--           FT245_MODE    => ,
--           FIFO_RX_POP   => ,

--           -- Salidas de control de cámara.
--           REQUEST_IMAGE =>
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
           FIFO_RX_VALUE  : in STD_LOGIC_VECTOR(7 downto 0);
           
           -- Entradas de control de cámara
           FRAME_END      : in STD_LOGIC;
           
           -- Salidas de control de FT245.
           FT245_MODE     : out STD_LOGIC;
           FIFO_RX_POP    : out STD_LOGIC;
           
           -- Salidas de control de cámara.
           REQUEST_IMAGE  : out STD_LOGIC
           );
end Control_FSM;

architecture Behavioral of Control_FSM is

    -- Tipo y señales de los estados de la FSM
    type STATE is (read_enable, request_image_send, wait_for_image_end, wait_for_write_end);
    signal state_reg, state_next: STATE;
    
    -- Señales de las salidas registradas de la FSM
    signal mode_reg, mode_next         : STD_LOGIC;
    signal request_reg, request_next   : STD_LOGIC;
    signal fifo_pop_reg, fifo_pop_next : STD_LOGIC;

begin

----- State Register -----

process(CLK, RST)
begin

    if RST = '1' then    -- Reset asíncrono
        state_reg    <= read_enable;
        mode_reg     <= '0';
        request_reg  <= '0';
        fifo_pop_reg <= '0';
    elsif CLK'event and CLK = '1' then
        state_reg    <= state_next;
        mode_reg     <= mode_next;
        request_reg  <= request_next;
        fifo_pop_reg <= fifo_pop_next;
    end if;

end process;

----- END State Register -----

----- Next State Logic -----

process (state_reg, mode_reg, fifo_rx_empty, fifo_tx_empty, FRAME_END, FIFO_RX_VALUE)
begin

    -- Asignaciones por defecto para evitar latches.
    state_next    <= state_reg;
    mode_next     <= '0';
    request_next  <= '0';
    fifo_pop_next <= '0';
    
    -- Máquina de estados
    case state_reg is      
        
        when read_enable =>     
            if fifo_rx_empty = '0' and FIFO_RX_VALUE = x"A5" then
                state_next <= request_image_send;
                fifo_pop_next <= '1';
            elsif fifo_rx_empty = '0' then
                fifo_pop_next <= '1';                
            end if;
            
        when request_image_send =>
            mode_next <= '1';
            request_next <= '1';
            state_next   <= wait_for_image_end;
            
        when wait_for_image_end =>
            mode_next <= '1';
            
            if FRAME_END = '1' then
                state_next <= wait_for_write_end;
            end if;            
        
        when wait_for_write_end =>
            mode_next <= '1';
            
            if fifo_tx_empty = '1' then
                state_next <= read_enable;
            end if;
        
        when others =>
            -- Estado por defecto (no debería ocurrir)
            mode_next <= '0';
            request_next <= '0';
            state_next <= read_enable;
        
    end case;

end process;

----- END Next State Logic ----- 

----- Output Logic -----

FT245_MODE    <= mode_reg;
REQUEST_IMAGE <= request_reg;
FIFO_RX_POP   <= fifo_pop_reg;

----- END Output Logic -----

end Behavioral;
