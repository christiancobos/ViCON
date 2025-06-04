--------------------------------------------------------------------------------
--  Autor:       Christian Diego Cobos Marcos
--  DNI:         77438323Z
--  Fecha:       16/01/2024
--  Curso:       MSEEI 2023-2024
--  Descripción: EF31 - FT245
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
    Generic (
              N : NATURAL := 2000000                     -- Final de cuenta para contador FREE COUNTER. (Ajustado a 40 milisegundos)
             );
             
    Port ( CLK     : in    STD_LOGIC;                       -- Señal de reloj.
           SW      : in    STD_LOGIC_VECTOR (15 downto 0);  -- Switches. (15 izquierda --> 0 derecha)
           BTN     : in    STD_LOGIC_VECTOR (4  downto 0);  -- Botones. (0 central, 1 superior, 2 izquierda, 3 inferior, 4 derecha)
           LED     : out   STD_LOGIC_VECTOR (15 downto 0);  -- LEDs sobre los switches. (15 izquierda --> 0 derecha)
           CAT     : out   STD_LOGIC_VECTOR (7  downto 0);  -- Cátodos de los segmentos.
           AN      : out   STD_LOGIC_VECTOR (3  downto 0);  -- Ánodos de los dígitos (3 izquierda -->0 derecha).
           DATA    : inout STD_LOGIC_VECTOR (7  downto 0);  -- Datos de entrada/salida de FT245
           RXFn    : in    STD_LOGIC;
           TXEn    : in    STD_LOGIC;
           RDn     : out   STD_LOGIC;
           WRn     : out   STD_LOGIC;
           OEn     : out   STD_LOGIC;                       -- No se usa en el modo FT245 Asíncrono.
           SIWUn   : out   STD_LOGIC;                       -- Si se conecta, debe estar fijado a HIGH.
           CLKOUT  : in    STD_LOGIC;                       -- No se usa en el modo FT245 Asíncrono.
           PWRSAVn : out   STD_LOGIC);                      -- Si se conecta, debe estar fijado a HIGH.
end TOP;

architecture Behavioural of TOP is

    -- Declaración MMCM.
    component clk_wiz_0
    port
     (
          -- Clock out ports
          clk_out1          : out    std_logic;  -- Salida de reloj.
          -- Status and control signals
          reset             : in     std_logic;  -- Señal de reset.
          locked            : out    std_logic;  -- Flag de indicación de la estabilidad.
          -- Clock in ports
          clk_in1           : in     std_logic   -- Entraada del oscilador.
     );
    end component;

    -- Señales MMCM
    signal MCLK:    STD_LOGIC;           -- Señal de reloj a 50 MHz.
    signal LOCKED:  STD_LOGIC;           -- Indica que la señal de reloj es estable.
    alias  CLK_RST: STD_LOGIC is BTN(0); -- La señal de reset del reloj se genera con el botón central.
    signal RST:     STD_LOGIC;           -- Señal de reset generada a partir de LOCKED.

    -- Señales display
    signal DDi: STD_LOGIC_VECTOR (15 downto 0);
    signal DPi: STD_LOGIC_VECTOR (3 downto 0);
    
    -- Señal para free counter.
    signal FREE_COUNTER: NATURAL range 0 to N-1;        -- Valor de la cuenta.
    signal COUNT_END:    STD_LOGIC;      -- Flag de final de cuenta, habilitará el contador BCD.
    
    -- Señales FT245
    signal OUTPUT_DATA: STD_LOGIC_VECTOR (7 downto 0);
    signal INPUT_DATA : STD_LOGIC_VECTOR (7 downto 0);
    
begin

   -------------------------------------------------------------------------------------------------
   -------------------------------------------INCOMPLETO--------------------------------------------
   -------------------------------------------------------------------------------------------------

    -- MODULOS
    
    ----- MMCM -----
    miMMCM : clk_wiz_0
    port map ( 
        -- Clock in ports
        clk_in1  => CLK,      -- Señal de reloj del oscilador.
        -- Clock out ports  
        clk_out1 => MCLK,     -- Salida a 50 MHz.
        -- Status and control signals                
        reset    => CLK_RST,  -- Reset (BTN(0)).
        locked   => LOCKED    -- Señal de indicación de salida estable (1-estable; 0-inestable).
    );
    ----- END MMCM. -----
    
    -- Reset global. -----
    RST <= not LOCKED;            -- Asignación del valor a la señal de reset.
    ----- END Reset global. -----
    
    ----- Contador FREE RUNNING. -----
    process (MCLK)
    begin
        if rising_edge(MCLK) then
            if RST = '1' then
                FREE_COUNTER <= 0;
                COUNT_END <= '0';
            elsif FREE_COUNTER = (N - 1) then
                FREE_COUNTER <= 0;
                COUNT_END <= '1';  -- Señal que indica el final del ciclo
            else
                FREE_COUNTER <= FREE_COUNTER + 1;
                COUNT_END <= '0';
            end if;
        end if;
    end process;
    ----- END Contador FREE RUNNING. -----
    
    --- Instancia FT245 -----
--    FT245_inst: entity work.FT245
--    Port map ( 
--           CLK   => MCLK,                      -- Señal de reloj.
--           reset => RST,                      -- Señal de reset.
--           DIN   => ,  -- Dato de entrada/salida.
--           wr_en => ,                      -- Señal de control para habilitar escritura.
--           rd_en => ,                       -- Señal de control para habilitar lectura.
--           ready_rx => open,                   -- Flag de estado de recepcion.
--           ready_tx => open,                   -- Flag de estado de transmisión.
--           TXEn  => ,                      -- Señal de control para solizitar que se escriban datos a la salida.
--           WRn   => ,                      -- Flag de escritura del dato.
--           RXFn => ,                        -- Señal de control para habilitar que se lean datos.
--           RDn => open,                        -- Flag de lectura del dato.
--           DATA_rx  => DDi(15 downto 8),  -- Dato recibido.
--           DATA_tx  => SW(15 downto 8) -- Dato a transmitir.
--     );
    --- END Instancia FT245 -----
    
    ----- TX Interface -----
    FT245_instTx: entity work.FT245_TxIF
    port map(
        clk   => MCLK,
        reset => RST,
        -- USER IO -----------------------------
        DIN   => INPUT_DATA, -- i [7:0]
        wr_en => OEn,         -- i
        ready => OPEN,        -- o
        -- FT245-like interface ----------------
        TXEn  => TXEn,        -- i
        WRn   => WRn,         -- o
        DATA  => OUTPUT_DATA          -- o [7:0]
    );
    ----- END TX Interface -----

    ----- RX Interface -----
    FT245_instRx: entity work.FT245_RxIF
    port map(
        clk   => MCLK,
        reset => RST,
        -- USER IO -----------------------------
        DIN   => DATA,        -- i [7:0]
        rd_en => '1',         -- i
        ready => open,        -- o
        -- FT245-like interface ----------------
        RXFn  => RXFn,        -- i
        RDn   => RDn,         -- o
        DATA  => INPUT_DATA   -- o [7:0]
    );
    ----- END RX FIFO -----
    
    ----- Triestado de entrada/salida de datos -----
    
    DATA <= OUTPUT_DATA when OEn = '1' else (others => 'Z');
    
    ----- END Triestado de entrada/salida de datos -----
    
    ----- Asignación de señales de Display -----
    
    DDi <= "00000000" & INPUT_DATA;
    DPi <= (others => '0');
    
    ----- END Asignación de señales de Display -----
    
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
    
    ----- Asingación de salidas -----
    
    OEn <= '1';
    PWRSAVn <= '1';
    
    ----- END Asignación de salidas -----
    
end Behavioural;
