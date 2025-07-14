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
              N : NATURAL := 256                     -- Final de cuenta para contador FREE COUNTER. (Ajustado a 40 milisegundos)
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
    signal OUTPUT_DATA, OUTPUT_NEXT, OUTPUT_NOW: STD_LOGIC_VECTOR (7 downto 0);
    signal INPUT_DATA : STD_LOGIC_VECTOR (7 downto 0);
    signal RX_EMPTY, TX_EMPTY: STD_LOGIC;
    signal FT245_MODE: STD_LOGIC;
    
    -- Prueba
    signal RX_POP  : STD_LOGIC;
    signal TX_PUSH : STD_LOGIC;
    signal TEST_DATA : STD_LOGIC_VECTOR (7 downto 0);
    signal TEST_MODE : STD_LOGIC;
    
    type STATE_TYPE is (IDLE, RX_READ, RX_POOP, TX_MODE, TX_PUUSH);
    signal main_state : STATE_TYPE := IDLE;
    
    signal data_buffer : STD_LOGIC_VECTOR(7 downto 0);  -- Para almacenar TEST_DATA
    signal DATA_TO_SHOW : STD_LOGIC_VECTOR(7 downto 0); 
    
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
    
    --- Instancia FT245 -----
    FT245_inst: entity work.FT245
    Port map (
           -- Control básico.
           CLK      => MCLK,                  -- Señal de reloj.
           reset    => RST,                   -- Señal de reset.
           
           -- Interfaz física FT245.
           DINOUT   => DATA,                  -- Dato de entrada/salida.
           TXEn     => TXEn,                  -- Señal de control para solizitar que se escriban datos a la salida.
           WRn      => WRn,                   -- Flag de escritura del dato.
           RXFn     => RXFn,                  -- Señal de control para habilitar que se lean datos.
           RDn      => RDn,              -- Flag de lectura del dato.
           
           -- Interfaz de datos hacia cámara 
           DATA_rx  => TEST_DATA,            -- Dato recibido.
           DATA_tx  => data_buffer,       -- Dato a transmitir
           
           -- Control 
           mode     => FT245_MODE,
           
           POP_RX   => RX_POP,
           RX_EMPTY => RX_EMPTY,
           
           PUSH_tx  => TX_PUSH,
           TX_EMPTY => TX_EMPTY
     );
    --- END Instancia FT245 -----
    
    ----- Instancia Módulo de control -----
    
    FSM_inst: entity work.Control_FSM
    port map (
           -- Control básico
           CLK           => MCLK,
           RST           => RST,
           
           -- Entradas de control de FT245.
           FIFO_RX_EMPTY => RX_EMPTY,
           FIFO_TX_EMPTY => TX_EMPTY,
           
           -- Salidas de control de FT245.
           FT245_MODE    => FT245_MODE
    );
    
    ----- END Instancia Módulo de control -----
    
    ----- Asignación de señales de Display -----
    
    process(MCLK, RST)
    begin
        if RST = '1' then
            main_state     <= IDLE;
            RX_POP         <= '0';
            TX_PUSH        <= '0';
            DATA_TO_SHOW   <= (others => '0');
            data_buffer    <= (others => '0');
    
        elsif rising_edge(MCLK) then
            -- Pulso por defecto
            RX_POP  <= '0';
            TX_PUSH <= '0';
    
            case main_state is
    
                when IDLE =>
                    if RX_EMPTY = '0' then
                        main_state <= RX_READ;
                    end if;
    
                when RX_READ =>
                    data_buffer  <= TEST_DATA;         -- Capturar dato
                    DATA_TO_SHOW <= TEST_DATA;         -- Mostrarlo
                    main_state   <= RX_POOP;
    
                when RX_POOP =>
                    RX_POP      <= '1';                -- Pulso para consumir dato
                    main_state  <= TX_MODE;
    
                when TX_MODE =>
                    if TX_EMPTY = '1' then             -- FIFO TX disponible
                        main_state <= TX_PUUSH;
                    end if;
    
                when TX_PUUSH =>
                    TX_PUSH    <= '1';                 -- Pulso para enviar
                    main_state <= IDLE;
    
                when others =>
                    main_state <= IDLE;
    
            end case;
        end if;
    end process;
    
    process(MCLK)
    begin
        if rising_edge(MCLK) then
            if (TX_PUSH = '1') then
                FREE_COUNTER <= FREE_COUNTER + 1;
            end if;
        end if;    
    end process;

    DDi(15 downto 8) <= std_logic_vector(to_unsigned(FREE_COUNTER, 8));
    DDI(7 downto 0) <= DATA_TO_SHOW;
    LED(0) <= FT245_MODE;
    LED(1) <= not TX_EMPTY;
    DDI(7 downto 0) <= DATA_TO_SHOW;
    LED(0) <= FT245_MODE;
    LED(1) <= not TX_EMPTY;
    DPi <= (others => '1');
    
    
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
    
    -- Prueba
    --TX_PUSH <= not RX_EMPTY;
    --RX_POP <= not RX_EMPTY;
    TEST_MODE <= not TX_EMPTY;
    
end Behavioural;
