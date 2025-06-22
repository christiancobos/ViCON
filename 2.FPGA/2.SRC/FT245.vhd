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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FT245 is
    Port ( CLK      : in  STD_LOGIC;                        -- Señal de reloj.x
           reset    : in  STD_LOGIC;                        -- Señal de reset.x
           DIN      : inout  STD_LOGIC_VECTOR (7 downto 0); -- Dato de entrada/salida.x                                            ENTRADA INTERFAZ
           TXEn     : in  STD_LOGIC;                        -- Señal de control para solizitar que se escriban datos a la salida. ENTRADA INTERFAZx
           --RXFn     : in STD_LOGIC;                         -- Señal de control para habilitar que se lean datos de la salida.    ENTRADA INTERFAZx
           WRn      : out STD_LOGIC;                        -- Flag de escritura del dato.                                        ENTRADA INTERFAZx
           --RDn      : out STD_LOGIC;                        -- Flag de lectura del dato.                                          ENTRADA INTERFAZ x                    
           --DATA_rx  : out STD_LOGIC_VECTOR (7 downto 0);    -- Dato recibido.                 HACIA CONTROL DE CÁMARAx
           --POP_RX   : in STD_LOGIC;                         -- Indicación de la cámara para recibir datox
           --RX_EMPTY : out STD_LOGIC;                        -- FIFO de recepción vacía.x
           --RX_DONE  : out STD_LOGIC;
           --ready    : out STD_LOGIC;
           --RX_FULL:   out STD_LOGIC;
           DATA_tx  : in STD_LOGIC_VECTOR (7 downto 0);     -- Dato a transmitir.             DESDE CONTROL DE CÁMARAx
           PUSH_TX  : in STD_LOGIC;                         -- Flag de recepción de dato a transmitir.x
           TX_FULL  : out STD_LOGIC                         -- FIFO de transmisión llena.x
           );
end FT245;

architecture Behavioral of FT245 is

    -- Señales internas para conexión con máquina de estados
    --signal ready_rx: STD_LOGIC; -- Flag de estado de recepcion.
    signal ready_tx: STD_LOGIC; -- Flag de estado de transmisión.

    -- Señales internas para habilitación de escritura y lectura.
    signal wr_en: STD_LOGIC;
    --signal rd_en: STD_LOGIC;

    -- Señales de conexión Interfaz-FIFO.
    signal fifo_tx_out     : STD_LOGIC_VECTOR (7 downto 0);
    
    --signal received_data   : STD_LOGIC_VECTOR (7 downto 0);
    --signal transmited_data : STD_LOGIC_VECTOR (7 downto 0);
    
    --signal data_push       : STD_LOGIC;
    signal data_pop        : STD_LOGIC;
    
    --signal fifo_rx_full    : STD_LOGIC;
    signal fifo_tx_empty   : STD_LOGIC;
begin

    ----- FT245 RX Interface -----
--    FT245_instRx: entity work.FT245_RxIF
--    port map(
--        clk   => CLK,
--        reset => reset,
--        -- USER IO -----------------------------
--        DIN   => DIN,             -- i [7:0]
--        rd_en => rd_en,           -- i         --- Lógica de control
--        ready => ready_rx,        -- o
--        -- FT245-like interface ----------------
--        RXFn  => RXFn,            -- i
--        RDn   => RDn,    -- o         --- Lógica de control
--        DATA  => received_data,   -- o [7:0]
--        RX_DONE_TICK => data_push -- o
--    );
    ----- END FT245 RX INTERFACE -----
    
    ----- FIFO RX -----
--    FIFO_instRx: entity work.FIFO
--    port map(
--        CLK   => CLK,           -- Señal de reloj.
--        RST   => reset,         -- Flag reset.
--        DIN   => received_data, -- Dato de entrada (ancho de palabra W).
--        PUSH  => data_push,     -- Flag de introducción de dato.
--        FULL  => fifo_rx_full,  -- Indica FIFO llena.
--        DOUT  => DATA_rx,       -- Dato de salida (ancho de palabra W).
--        POP   => POP_RX,        -- Flag de retirada de dato.
--        EMPTY => RX_EMPTY       -- Indica FIFO vacía.
--    );
    ----- END FIFO RX -----
    
    ----- Habilitación de RX -----
    
    --rd_en <= not fifo_rx_full;
    
    ----- END Habilitación de RX -----
        
    ----- TX Interface -----
    FT245_instTx: entity work.FT245_TxIF
    port map(
        clk   => CLK,
        reset => reset,
        -- USER IO -----------------------------
        DIN   => fifo_tx_out,    -- i [7:0]
        wr_en => wr_en,          -- i
        ready => ready_tx,       -- o
        -- FT245-like interface ----------------
        TXEn  => TXEn,           -- i
        WRn   => WRn,            -- o
        DATA  => DIN,            -- o [7:0]
        TX_DONE_TICK => data_pop -- o
    );
    ----- END TX Interface -----
    
    ----- FIFO TX -----
    FIFO_instTx: entity work.FIFO
    port map(
        CLK   => CLK,           -- Señal de reloj.
        RST   => reset,         -- Flag reset.
        DIN   => DATA_tx,       -- Dato de entrada (ancho de palabra W).
        PUSH  => PUSH_TX,  -- Flag de introducción de dato.
        FULL  => TX_FULL,       -- Indica FIFO llena.
        DOUT  => fifo_tx_out,       -- Dato de salida (ancho de palabra W).
        POP   => data_pop,      -- Flag de retirada de dato.
        EMPTY => fifo_tx_empty  -- Indica FIFO vacía.
    );
    ----- END FIFO TX -----
    
    ----- Habilitación de TX -----
    
    wr_en <= not fifo_tx_empty;
    
    ----- END Habilitación de TX -----
        
    ----- PRUEBA -----
    
--    RX_DONE <= data_push;
--    ready <= ready_rx;
--    RX_FULL <= fifo_rx_full;

end Behavioral;
