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
    Port ( CLK   : in  STD_LOGIC;                        -- Señal de reloj.
           reset : in  STD_LOGIC;                        -- Señal de reset.
           DIN   : inout  STD_LOGIC_VECTOR (7 downto 0); -- Dato de entrada/salida.
           wr_en : in  STD_LOGIC;                        -- Señal de control para habilitar escritura.
           rd_en : in STD_LOGIC;                         -- Señal de control para habilitar lectura.
           TXEn  : in  STD_LOGIC;                        -- Señal de control para solizitar que se escriban datos a la salida.
           RXFn : in STD_LOGIC;                          -- Señal de control para habilitar que se lean datos de la salida.
           WRn   : out STD_LOGIC;                        -- Flag de escritura del dato.
           RDn : out STD_LOGIC;                          -- Flag de lectura del dato.
           ready_rx : out STD_LOGIC;                     -- Flag de estado de recepcion.
           ready_tx : out STD_LOGIC;                     -- Flag de estado de transmisión.
           DATA_rx  : in STD_LOGIC_VECTOR (7 downto 0);  -- Dato recibido.
           DATA_tx  : in STD_LOGIC_VECTOR (7 downto 0)); -- Dato a transmitir.
end FT245;

architecture Behavioral of FT245 is

    -- Señales internas para flags de escritura y lectura.
    signal internal_WRn: STD_LOGIC;
    signal internal_RDn: STD_LOGIC;

    -- Señales de conexión Interfaz-FIFO.
    signal fifo_rx_out    : STD_LOGIC_VECTOR (7 downto 0);
    signal fifo_tx_out    : STD_LOGIC_VECTOR (7 downto 0);
    
    signal received_data  : STD_LOGIC_VECTOR (7 downto 0);
    signal transmited_data: STD_LOGIC_VECTOR (7 downto 0);

begin

    ----- TRIESTADO. -----
    DIN <= transmited_data when wr_en = '1' else (others => 'Z');
    ----- END TRIESTADO. -----

    ----- RX Interface -----
--    FT245_instRx: entity work.FT245_RxIF
--    port map(
--        clk   => CLK,
--        reset => reset,
--        -- USER IO -----------------------------
--        DIN   => fifo_rx_out, -- i [7:0]
--        rd_en => rd_en,       -- i
--        ready => ready_rx,    -- o
--        -- FT245-like interface ----------------
--        RXFn  => RXFn,        -- i
--        RDn   => RDn,         -- o
--        DATA  => DIN          -- o [7:0]
--    );
    ----- END RX INTERFACE -----
    
    ----- RX FIFO -----
--    FIFO_instRx: entity work.FIFO
--    port map(
--        CLK   => CLK,          -- Señal de reloj.
--        RST   => reset,        -- Flag reset.
--        DIN   => fifo_rxout,     -- Dato de entrada (ancho de palabra W).
--        PUSH  => RDn,          -- Flag de introducción de dato.
--        FULL  => open,         -- Indica FIFO llena.
--        DOUT  => fifo_rx_out,  -- Dato de salida (ancho de palabra W).
--        POP   => internal_RDn, -- Flag de retirada de dato.
--        EMPTY => open          -- Indica FIFO vacía.
--    );
    ----- END RX FIFO -----
    
    ----- TX FIFO -----
--    FIFO_instTx: entity work.FIFO
--    port map(
--        CLK   => CLK,          -- Señal de reloj.
--        RST   => reset,        -- Flag reset.
--        DIN   => DATA_Tx,      -- Dato de entrada (ancho de palabra W).
--        PUSH  => wr_en,        -- Flag de introducción de dato.
--        FULL  => open,         -- Indica FIFO llena.
--        DOUT  => fifo_tx_out,  -- Dato de salida (ancho de palabra W).
--        POP   => internal_WRn, -- Flag de retirada de dato.
--        EMPTY => open          -- Indica FIFO vacía.
--    );
    ----- END TX FIFO -----
    
    ----- TX Interface -----
--    FT245_instTx: entity work.FT245_TxIF
--    port map(
--        clk   => CLK,
--        reset => reset,
--        -- USER IO -----------------------------
--        DIN   => fifo_tx_out, -- i [7:0]
--        wr_en => wr_en,       -- i
--        ready => ready_tx,    -- o
--        -- FT245-like interface ----------------
--        TXEn  => TXEn,        -- i
--        WRn   => WRn,         -- o
--        DATA  => DIN          -- o [7:0]
--    );
    ----- END TX Interface -----
    
    ----- Conexiones con salidas -----
    WRn <= internal_WRn;
    RDn <= internal_RDn;
    ----- END Conexiones con salidas -----


end Behavioral;
