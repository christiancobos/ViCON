--------------------------------------------------------------------------------
--  Autor:       Christian Diego Cobos Marcos
--  DNI:         77438323Z
--  Fecha:       16/01/2024
--  Curso:       MSEEI 2023-2024
--  Descripción: EF31 - FT245
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 	INSTANCE TEMPLATE  --------------------------------------------------------
-------------------------------------------------------------------------------

--FT245_inst: entity work.FT245
--    Port map (
--           -- Control básico.
--           CLK      => ,                  -- Señal de reloj.
--           reset    => ,                   -- Señal de reset.
           
--           -- Interfaz física FT245.
--           DINOUT   => ,                  -- Dato de entrada/salida.
--           TXEn     => ,                  -- Señal de control para solizitar que se escriban datos a la salida.
--           WRn      => ,                   -- Flag de escritura del dato.
--           RXFn     => ,                  -- Señal de control para habilitar que se lean datos.
--           RDn      => ,              -- Flag de lectura del dato.
           
--           -- Interfaz de datos hacia cámara 
--           DATA_rx  => ,            -- Dato recibido.
--           DATA_tx  => ,       -- Dato a transmitir
           
--           -- Control 
--           mode     => ,
           
--           POP_RX   => ,
--           RX_EMPTY => ,
           
--           PUSH_tx  => ,
--           TX_FULL  => 
--     );



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FT245 is

    Port ( 
           -- Control básico.
           CLK      : in  STD_LOGIC;                        -- Señal de reloj.x
           reset    : in  STD_LOGIC;                        -- Señal de reset.x
           
           -- Interfaz física FT245.
           DINOUT   : inout  STD_LOGIC_VECTOR (7 downto 0); -- Dato de entrada/salida.x                                            ENTRADA INTERFAZ
           TXEn     : in  STD_LOGIC;                        -- Señal de control para solizitar que se escriban datos a la salida. ENTRADA INTERFAZx
           RXFn     : in STD_LOGIC;                         -- Señal de control para habilitar que se lean datos de la salida.    ENTRADA INTERFAZx
           WRn      : out STD_LOGIC;                        -- Flag de escritura del dato.                                        ENTRADA INTERFAZx
           RDn      : out STD_LOGIC;                        -- Flag de lectura del dato.
           
           --  Interfaz de datos hacia FPGA.            
           DATA_rx  : out STD_LOGIC_VECTOR (7 downto 0);    -- Dato recibido.                 HACIA CONTROL DE CÁMARAx
           DATA_tx  : in STD_LOGIC_VECTOR (7 downto 0);     -- Dato a transmitir.             DESDE CONTROL DE CÁMARAx

           -- Interfaz de control
           mode     : in STD_LOGIC;                         -- Selección de modo recepción ('0') o transmisión ('1')
           
           POP_RX   : in STD_LOGIC;                         -- Indicación de la cámara para recibir dato
           RX_EMPTY : out STD_LOGIC;                        -- Flag de FIFO de recepción vacía.
           
           PUSH_TX  : in STD_LOGIC;                         -- Flag de recepción de dato a transmitir.x
           TX_EMPTY  : out STD_LOGIC                         -- Flag de FIFO de transmisión llena.
           );
end FT245;

architecture Behavioral of FT245 is

    -- Señales internas para habilitación de escritura y lectura.
    signal wr_en: STD_LOGIC;
    signal rd_en: STD_LOGIC;

    -- Señales de conexión Interfaz-FIFO.
    signal fifo_tx_out     : STD_LOGIC_VECTOR (7 downto 0);
    
    signal received_data   : STD_LOGIC_VECTOR (7 downto 0);
    signal transmited_data : STD_LOGIC_VECTOR (7 downto 0);
    
    signal data_push       : STD_LOGIC;
    signal data_pop        : STD_LOGIC;
    
    signal fifo_rx_full    : STD_LOGIC;
    signal fifo_tx_empty   : STD_LOGIC;
    signal fifo_tx_full    : STD_LOGIC;
    
    -- Señal de salida para triestado
    signal output          : STD_LOGIC_VECTOR (7 downto 0);
begin

    ----- FT245 RX Interface -----
    FT245_instRx: entity work.FT245_RxIF
    port map(
        clk   => CLK,
        reset => reset,
        -- USER IO -----------------------------
        DIN   => DINOUT,           -- i [7:0]
        rd_en => rd_en,           -- i         --- Lógica de control
        ready => open,            -- o
        -- FT245-like interface ----------------
        RXFn  => RXFn,            -- i
        RDn   => RDn,             -- o         --- Lógica de control
        DATA  => received_data,   -- o [7:0]
        RX_DONE_TICK => data_push -- o
    );
    ----- END FT245 RX INTERFACE -----
    
    ----- FIFO RX -----
    FIFO_instRx: entity work.FIFO
    port map(
        CLK   => CLK,           -- Señal de reloj.
        RST   => reset,         -- Flag reset.
        DIN   => received_data, -- Dato de entrada (ancho de palabra W).
        PUSH  => data_push,     -- Flag de introducción de dato.
        FULL  => fifo_rx_full,  -- Indica FIFO llena.
        DOUT  => DATA_rx,       -- Dato de salida (ancho de palabra W).
        POP   => POP_RX,        -- Flag de retirada de dato.
        EMPTY => RX_EMPTY       -- Indica FIFO vacía.
    );
    ----- END FIFO RX -----
    
    ----- Habilitación de RX -----
    
    rd_en <= not mode and not fifo_rx_full;
    
    ----- END Habilitación de RX -----
        
    ----- TX Interface -----
    FT245_instTx: entity work.FT245_TxIF
    port map(
        clk   => CLK,
        reset => reset,
        -- USER IO -----------------------------
        DIN   => fifo_tx_out,    -- i [7:0]
        wr_en => wr_en,          -- i
        ready => open,           -- o
        -- FT245-like interface ----------------
        TXEn  => TXEn,           -- i
        WRn   => WRn,            -- o
        DATA  => output,         -- o [7:0]
        TX_DONE_TICK => data_pop -- o
    );
    ----- END TX Interface -----
    
    ----- FIFO TX -----
    FIFO_instTx: entity work.FIFO
    port map(
        CLK   => CLK,           -- Señal de reloj.
        RST   => reset,         -- Flag reset.
        DIN   => DATA_tx,       -- Dato de entrada (ancho de palabra W).
        PUSH  => PUSH_TX,       -- Flag de introducción de dato.
        FULL  => fifo_tx_full,  -- Indica FIFO llena.
        DOUT  => fifo_tx_out,   -- Dato de salida (ancho de palabra W).
        POP   => data_pop,      -- Flag de retirada de dato.
        EMPTY => fifo_tx_empty  -- Indica FIFO vacía.
    );
    ----- END FIFO TX -----
    
    ----- Habilitación de TX -----
    
    wr_en <= mode and not fifo_tx_empty;
    
    ----- END Habilitación de TX -----
    
    ----- Triestado E/S -----
    
    DINOUT <= output when mode = '1' else (others => 'Z');
    
    ----- END Triestado E/S -----
    
    ----- Conexión salidas -----
    
    TX_EMPTY <= fifo_tx_empty;
    
    ----- END Conexión salidas -----

end Behavioral;
