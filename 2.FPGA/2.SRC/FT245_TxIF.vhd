--------------------------------------------------------------------------------
--  Autor:       Christian Diego Cobos Marcos
--  DNI:         77438323Z
--  Fecha:       16/01/2024
--  Curso:       MSEEI 2023-2024
--  Descripción: EF31 - Ft245-TX
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- INSTANCE TEMPLATE -----------------------------------------------------------
--------------------------------------------------------------------------------
-- FT245_inst: entty FT245_IF
-- port map{
--  clk   => MCLK,
--  reset => MRST,
--  -- USER IO -----------------------------
--  DIN   => UserDataIn,       -- i [7:0]
--  wr_en => User_wr_en,       -- i
--  ready => User_rdy_flag,    -- o
--  -- FT245-like interface ----------------
--  TXEn  => FT245_TXEn,       -- i
--  WRn   => FT245_WRn,        -- o
--  DATA  => FT245_D           -- o [7:0]
-- };

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FT245_TxIF is
    Port ( CLK          : in  STD_LOGIC;                      -- Señal de reloj.
           reset        : in  STD_LOGIC;                      -- Señal de reset.
           DIN          : in  STD_LOGIC_VECTOR (7 downto 0);  -- Dato de entrada.
           wr_en        : in  STD_LOGIC;                      -- Señal de control para habilitar escritura.
           ready        : out STD_LOGIC;                      -- Flag de estado de escritura.
           TXEn         : in  STD_LOGIC;                      -- Señal de control para solizitar que se escriban datos a la salida.
           WRn          : out STD_LOGIC;                      -- Flag de escritura del dato.
           DATA         : out STD_LOGIC_VECTOR (7 downto 0);  -- Dato de salida.
           TX_DONE_TICK : out STD_LOGIC);                     -- Flag de dato disponible para FIFO.
end FT245_TxIF;

architecture Behavioral of FT245_TxIF is

    -- Señales sincronizador.
    signal r_reg    : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');             -- Señal del registro de desplazamiento.
    alias  sync_TXEn: STD_LOGIC is r_reg(0);                                       -- Alias para valor sincronizado del TXen.

    -- Tipo y señales de los estados de la FSM.
    type STATES is (idle, wait_for_TXE, output_data, write_1, write_2, write_3);
    signal state_reg, state_next: STATES;
    
    -- Señales para salidas registradas de la interfaz
    signal ready_reg, ready_next    : STD_LOGIC                    := '1';             -- Señales para flag "ready". Valor inicial en Idle.
    signal WRn_reg, WRn_next        : STD_LOGIC                    := '1';             -- Señales para flag de escritura. Valor inicial en Idle.
    signal DATA_reg, DATA_next      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- Señales para salida de datos Valor inicial en Idle.
    signal TX_DONE_reg, TX_DONE_next: STD_LOGIC                    := '0';             -- Señales para flag de FIFO. Valor inicial en Idle.

begin

    ----- Sincronizador -----
    
    process(CLK, reset)
    begin
        if reset = '1' then                -- Reset asíncrono
            r_reg <= (others => '1');
        elsif CLK'event and CLK = '1' then
            r_reg <= TXEn & r_reg(1);
        end if;
    end process;
    
    ----- END Sincronizador -----

    ----- State register -----
    
    process(CLK, reset)
    begin
        if reset = '1' then              -- Reset asíncrono.
            state_reg   <= idle;
            ready_reg   <= '1';
            WRn_reg     <= '1';
            DATA_reg    <= (others => '0');
            TX_DONE_reg <= '0';
        elsif CLK'event and CLK='1' then -- Actualización de los estados.
            state_reg   <= state_next;
            ready_reg   <= ready_next;
            WRn_reg     <= WRn_next;
            DATA_reg    <= DATA_next;
            TX_DONE_reg <= TX_DONE_next;
        end if;
        
    end process;
    
    ----- END State register -----
    
    ----- Next state logic -----
    
    process(state_reg, ready_reg, WRn_reg, DATA_reg, wr_en, sync_TXEn, DIN)
    begin
        -- Asignación por defecto para evitar latches.
        state_next   <= state_reg;
        ready_next   <= ready_reg;
        WRn_next     <= WRn_reg;
        DATA_next    <= DATA_reg;
        TX_DONE_next <= TX_DONE_reg;
        
        case state_reg is
            when idle =>
                -- Se baja el flag de la FIFO.
                TX_DONE_NEXT <= '0';
                
                -- En estado IDLE, se espera a la habilitación de escritura.
                if wr_en = '1' then
                    state_next <= wait_for_TXE;
                    ready_next <= '0';
                end if;
                
            when wait_for_TXE =>
                -- Se baja el flag de la FIFO.
                TX_DONE_NEXT <= '0';
                
                -- Se espera a que haya datos disponibles para enviar.
                if sync_TXEn = '0' then
                    state_next <= output_data;
                    DATA_next  <= DIN;
                end if;
                
            when output_data =>
                -- Ciclo para poner datos en el bus.
                state_next <= write_1;
                WRn_next   <= '0';
                
            when write_1 =>
                -- Primer ciclo de escritura.
                state_next <= write_2;
                
            when write_2 =>
                -- Segundo ciclo de escritura
                state_next <= write_3;
                
            when write_3 =>
                -- Tercer y último ciclo de escritura
                WRn_next   <= '1';
                TX_DONE_NEXT <= '1';            -- Se indica a la FIFO que proporcione nuevo dato.
                
                if wr_en = '1' then
                    state_next <= wait_for_TXE; -- Verifica si hay más datos
                else
                    state_next <= idle;
                    ready_next <= '1';          -- Se indica que la escritura ha terminado
                end if;
                    
            end case;
    
    end process;

    ----- END Next state logic -----
    
    ----- Conexión señales con salidas -----
    
    ready <= ready_reg;
    WRn   <= WRn_reg;
    DATA  <= DATA_reg;
    TX_DONE_tick <= TX_DONE_REG;
    
    ----- END Conexión señales con salidas -----
end Behavioral;
