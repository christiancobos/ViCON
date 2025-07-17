--------------------------------------------------------------------------------
--  Autor:       Christian Diego Cobos Marcos
--  DNI:         77438323Z
--  Fecha:       16/07/2025
--  Curso:       MSEEI 2024-2025
--  Descripci�n: ViCON - TOP
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP is
             
    Port ( CLK     : in    STD_LOGIC;                       -- Se�al de reloj.
           SW      : in    STD_LOGIC_VECTOR (15 downto 0);  -- Switches. (15 izquierda --> 0 derecha)
           BTN     : in    STD_LOGIC_VECTOR (4  downto 0);  -- Botones. (0 central, 1 superior, 2 izquierda, 3 inferior, 4 derecha)
           LED     : out   STD_LOGIC_VECTOR (15 downto 0);  -- LEDs sobre los switches. (15 izquierda --> 0 derecha)
           CAT     : out   STD_LOGIC_VECTOR (7  downto 0);  -- C�todos de los segmentos.
           AN      : out   STD_LOGIC_VECTOR (3  downto 0);  -- �nodos de los d�gitos (3 izquierda -->0 derecha).
           DATA    : inout STD_LOGIC_VECTOR (7  downto 0);  -- Datos de entrada/salida de FT245
           RXFn    : in    STD_LOGIC;
           TXEn    : in    STD_LOGIC;
           RDn     : out   STD_LOGIC;
           WRn     : out   STD_LOGIC;
           OEn     : out   STD_LOGIC;                       -- No se usa en el modo FT245 As�ncrono.
           SIWUn   : out   STD_LOGIC;                       -- Si se conecta, debe estar fijado a HIGH.
           CLKOUT  : in    STD_LOGIC;                       -- No se usa en el modo FT245 As�ncrono.
           PWRSAVn : out   STD_LOGIC);                      -- Si se conecta, debe estar fijado a HIGH.
end TOP;

architecture Behavioural of TOP is

    -- Declaraci�n MMCM.
    component clk_wiz_0
    port
     (
          -- Clock out ports
          clk_out1          : out    std_logic;  -- Salida de reloj.
          -- Status and control signals
          reset             : in     std_logic;  -- Se�al de reset.
          locked            : out    std_logic;  -- Flag de indicaci�n de la estabilidad.
          -- Clock in ports
          clk_in1           : in     std_logic   -- Entraada del oscilador.
     );
    end component;

    -- Se�ales MMCM
    signal MCLK:    STD_LOGIC;           -- Se�al de reloj a 50 MHz.
    signal LOCKED:  STD_LOGIC;           -- Indica que la se�al de reloj es estable.
    alias  CLK_RST: STD_LOGIC is BTN(0); -- La se�al de reset del reloj se genera con el bot�n central.
    signal RST:     STD_LOGIC;           -- Se�al de reset generada a partir de LOCKED.

    -- Se�ales display
    signal DDi: STD_LOGIC_VECTOR (15 downto 0);
    signal DPi: STD_LOGIC_VECTOR (3 downto 0);
    
    -- Se�ales FT245
    signal OUTPUT_NEXT, OUTPUT_NOW: STD_LOGIC_VECTOR (7 downto 0);
    signal RX_EMPTY, TX_EMPTY, TX_FULL: STD_LOGIC;
    signal tx_push_deb : STD_LOGIC;
    signal tx_push_edge: STD_LOGIC;
    signal FT245_MODE: STD_LOGIC;
    signal RX_POP    : STD_LOGIC;
    
    -- Se�ales para contador 8 bits
    signal counter        : UNSIGNED(7 downto 0) := (others => '0');
    signal counter_enable : STD_LOGIC := '0';
    signal enviado        : STD_LOGIC := '0';
    type state_type is (IDLE, LOAD, WAITING, PUSH);
    signal state : state_type := IDLE;
    signal data_reg : STD_LOGIC_VECTOR(7 downto 0);
    
    
begin

   -------------------------------------------------------------------------------------------------
   -------------------------------------------INCOMPLETO--------------------------------------------
   -------------------------------------------------------------------------------------------------

    -- MODULOS
    
    ----- MMCM -----
    miMMCM : clk_wiz_0
    port map ( 
        -- Clock in ports
        clk_in1  => CLK,      -- Se�al de reloj del oscilador.
        -- Clock out ports  
        clk_out1 => MCLK,     -- Salida a 50 MHz.
        -- Status and control signals                
        reset    => CLK_RST,  -- Reset (BTN(0)).
        locked   => LOCKED    -- Se�al de indicaci�n de salida estable (1-estable; 0-inestable).
    );
    ----- END MMCM. -----
    
    -- Reset global. -----
    RST <= not LOCKED;            -- Asignaci�n del valor a la se�al de reset.
    ----- END Reset global. -----
    
    --- Instancia FT245 -----
    FT245_inst: entity work.FT245
    Port map (
           -- Control b�sico.
           CLK      => MCLK,                  -- Se�al de reloj.
           reset    => RST,                   -- Se�al de reset.
           
           -- Interfaz f�sica FT245.
           DINOUT   => DATA,                  -- Dato de entrada/salida.
           TXEn     => TXEn,                  -- Se�al de control para solizitar que se escriban datos a la salida.
           WRn      => WRn,                   -- Flag de escritura del dato.
           RXFn     => RXFn,                  -- Se�al de control para habilitar que se lean datos.
           RDn      => RDn,                   -- Flag de lectura del dato.
           
           -- Interfaz de datos hacia c�mara 
           DATA_rx  => OUTPUT_NOW,            -- Dato recibido.
           DATA_tx  => data_reg,              -- Dato a transmitir
           
           -- Control 
           mode     => '1',
           
           POP_RX   => RX_POP,
           RX_EMPTY => RX_EMPTY,
           
           PUSH_tx  => counter_enable,
           TX_EMPTY => TX_EMPTY,
           TX_FULL  => TX_FULL
     );
    --- END Instancia FT245 -----
    
    ----- Instancia M�dulo de control -----
    
    FSM_inst: entity work.Control_FSM
    port map (
           -- Control b�sico
           CLK           => MCLK,
           RST           => RST,
           
           -- Entradas de control de FT245.
           FIFO_RX_EMPTY => RX_EMPTY,
           FIFO_TX_EMPTY => TX_EMPTY,
           
           -- Salidas de control de FT245.
           FT245_MODE    => FT245_MODE
    );
    
    ----- END Instancia M�dulo de control -----
    
    ----- Asignaci�n de se�ales de Display -----
    
    DDi(15 downto 0) <= (others => '0'); 
    DPi <= (others => '1');
    
    ----- END Asignaci�n de se�ales de Display -----
    
    ----- Instancia display -----
    Disp_inst: entity work.DISPLAY(BlackBox)
    Port map (
    C   => MCLK,   -- CLK=50MHz
    DD  => DDi,    -- i(15:0)  DD(15:12)=D3 ... DD(3:0)=D0
    DP  => DPi,    -- i(3:0)   DotPoint DP3=izda ... DP0=dcha		
    CAT => CAT,    -- o(7:0)   CAT(7)=DP, CAT(6)=CG, CAT(0)=CA
    AN  => AN      -- o(3:0)   AN3=izda ... AN00dcha
    );
    ----- END Instancia display -----
    
    ----- Asingaci�n de salidas -----
    
    OEn <= '1';
    PWRSAVn <= '1';
    SIWUn   <= '1';
    
    ----- END Asignaci�n de salidas -----
    
    
    ----- PRUEBAS -----
    LED(15 downto 8) <= SW(15 downto 8); 
    LED(7 downto 0)  <= STD_LOGIC_VECTOR(counter);
    
    ----- Contador 8 Bits -----
    
    process (MCLK)
    begin
        if rising_edge(MCLK) then
            if RST = '1' then
                data_reg <= (others => '0');
                counter <= (others => '0');
                counter_enable <= '0';        
            elsif counter_enable = '1' then
                counter_enable <= '0';
            elsif TX_FULL = '0' then
                counter_enable <= '1';
                counter <= counter + 1;
                data_reg <= STD_LOGIC_VECTOR(counter);            
            else
                counter_enable <= '0';
            end if;
        
        end if;
    end process;

    ----- END Contador 8 Bits -----
    
    
end Behavioural;
