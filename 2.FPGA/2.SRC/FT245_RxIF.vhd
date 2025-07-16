--------------------------------------------------------------------------------
--  Autor:       Christian Diego Cobos Marcos
--  DNI:         77438323Z
--  Fecha:       16/07/2025
--  Curso:       MSEEI 2024-2025
--  Descripción: ViCON - Ft245 RX interface
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- INSTANCE TEMPLATE -----------------------------------------------------------
--------------------------------------------------------------------------------
-- FT245_inst: entty FT245_RxIF
-- port map{
--  clk   => MCLK,
--  reset => MRST,
--  -- USER IO -----------------------------
--  DIN   => UserDataIn,       -- i [7:0]
--  rd_en => User_rr_en,       -- i
--  ready => User_rdy_flag,    -- o
--  -- FT245-like interface ----------------
--  RXFn  => FT245_RXEn,       -- i
--  RDn   => FT245_RDn,        -- o
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

entity FT245_RxIF is
    Port ( CLK          : in STD_LOGIC;                       -- Señal de reloj.
           reset        : in STD_LOGIC;                       -- Señal de reset.
           DIN          : in STD_LOGIC_VECTOR (7 downto 0);   -- Dato de entrada.
           rd_en        : in STD_LOGIC;                       -- Señal de control para habilitar escritura.
           ready        : out STD_LOGIC;                      -- Flag de estado de escritura.
           RXFn         : in STD_LOGIC;                       -- Señal de control para solizitar que se escriban datos a la salida.
           RDn          : out STD_LOGIC;                      -- Flag de escritura del dato.
           DATA         : out STD_LOGIC_VECTOR (7 downto 0);  -- Dato de salida.
           RX_DONE_tick : out STD_LOGIC);                     -- Flag de dato disponible para FIFO.
end FT245_RxIF;

architecture Behavioral of FT245_RxIF is

    -- Señales sincronizador RXFn.
    signal r_reg    : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');             -- Señal del registro de desplazamiento.
    alias  sync_RXFn: STD_LOGIC is r_reg(0);     
    
    -- Tipo y señales de los estados de la FSM.
    type STATES is (idle, wait_for_RXF, read_1, read_2, read_3, wait_for_fifo_update, wait_for_rd_en, wait_for_not_RXF);
    signal state_reg, state_next: STATES;
    
    -- Señales para salidas registradas de la interfaz
    signal ready_reg, ready_next     : STD_LOGIC                    := '1';             -- Señales para flag "ready". Valor inicial en Idle.
    signal RDn_reg, RDn_next         : STD_LOGIC                    := '1';             -- Señales para flag de escritura. Valor inicial en Idle.
    signal DATA_reg, DATA_next       : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- Señales para entrada de datos. Valor inicial en Idle.
    signal RX_DONE_reg, RX_DONE_next : STD_LOGIC                    := '0';             -- Señales para flag de FIFO. Valor inicial en Idle.

begin

    ----- Sincronizador RXFn -----
    
    process(CLK, reset)
    begin
        if reset = '1' then                -- Reset asíncrono
            r_reg <= (others => '1');      -- Inicializa con todos 1s
        elsif rising_edge(CLK) then        -- Flanco de subida del reloj
            r_reg <= RXFn & r_reg(1);      -- Desplazamiento de la señal RXFn
        end if;
    end process;
    
    ----- END Sincronizador -----
    
    ----- State register -----
    
    process(CLK, reset)
    begin
        if reset = '1' then              -- Reset asíncrono.
            state_reg   <= idle;
            ready_reg   <= '1';
            RDn_reg     <= '1';
            DATA_reg    <= (others => '0');
            RX_DONE_reg <= '0';
        elsif CLK'event and CLK='1' then -- Actualización de los estados.
            state_reg   <= state_next;
            ready_reg   <= ready_next;
            RDn_reg     <= RDn_next;
            DATA_reg    <= DATA_next;
            RX_DONE_reg <= RX_DONE_next;
        end if;
        
    end process;
    
    ----- END State register -----
    
    ----- Next state logic -----
    
    process(state_reg, ready_reg, RDn_reg, DATA_reg, rd_en, sync_RXFn, DIN)
    begin
        -- Asignaciones por defecto para evitar latches
        state_next   <= state_reg;
        ready_next   <= ready_reg;
        RDn_next     <= RDn_reg;
        DATA_next    <= DATA_reg;
        RX_DONE_next <= '0';
    
        -- Máquina de estados
        case state_reg is
    
            when idle =>
                -- Se baja el flag de la FIFO
                RX_DONE_NEXT <= '0';
                
                -- En estado idle, espera habilitación de lectura
                if rd_en = '1' then
                    state_next <= wait_for_RXF;
                    ready_next <= '0';  -- Listo en bajo cuando inicia la lectura
                end if;
    
            when wait_for_RXF =>
                -- Espera hasta que indique datos disponibles
                if sync_RXFn = '0' then
                    RDn_next   <= '0';  -- Activa la lectura (RDn en bajo)
                    state_next <= read_1;
                end if;
    
            when read_1 =>
                -- Primer ciclo de lectura del dato
                state_next <= read_2;
    
            when read_2 =>
                -- Segundo ciclo de lectura del dato (mismo proceso que read_1)
                state_next <= read_3;
    
            when read_3 =>
                -- Tercer ciclo delectura del dato, realiza lectura y vuelve al estado inicial
                RDn_next     <= '1';  -- Termina la lectura (RDn en alto)
                DATA_next    <= DIN;  -- Lectura del dato
                RX_DONE_next <= '1';  -- Flag de lectura realizada para FIFO.
                state_next <= wait_for_fifo_update;
                
            when wait_for_fifo_update =>
                state_next   <= wait_for_rd_en;
                
            when wait_for_rd_en =>                
                if rd_en = '1' then
                    state_next <= wait_for_not_RXF;  -- Verifica si hay más datos
                else
                    state_next <= idle;
                    ready_next <= '1';  -- Indica que la lectura ha terminado
                end if;
    
            when wait_for_not_RXF =>
                -- Espera hasta que indique que no hay más datos
                if sync_RXFn = '1' then
                    state_next <= wait_for_RXF;  -- Vuelve a esperar más datos
                end if;
    
            when others =>
                -- Estado por defecto (no debería ocurrir)
                state_next <= idle;
                ready_next <= '0';
                RDn_next   <= '1';
                DATA_next  <= (others => '0');  -- Inicializa en 0 (por seguridad)
    
        end case;
    end process;

    ----- END Next state logic -----
    
    ----- Conexión señales con salidas -----
    
    ready        <= ready_reg;
    RDn          <= RDn_reg;
    DATA         <= DATA_reg;
    RX_DONE_tick <= RX_DONE_reg;
    
    ----- END Conexión señales con salidas -----

end Behavioral;
