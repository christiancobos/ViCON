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
             
    Port ( 
           -- Reloj
           CLK     : in    STD_LOGIC;                       -- Se�al de reloj.
           
           -- Controles de la placa
           SW      : in    STD_LOGIC_VECTOR (15 downto 0);  -- Switches. (15 izquierda --> 0 derecha)
           BTN     : in    STD_LOGIC_VECTOR (4  downto 0);  -- Botones. (0 central, 1 superior, 2 izquierda, 3 inferior, 4 derecha)
           LED     : out   STD_LOGIC_VECTOR (15 downto 0);  -- LEDs sobre los switches. (15 izquierda --> 0 derecha)
           CAT     : out   STD_LOGIC_VECTOR (7  downto 0);  -- C�todos de los segmentos.
           AN      : out   STD_LOGIC_VECTOR (3  downto 0);  -- �nodos de los d�gitos (3 izquierda -->0 derecha).
           
           -- FT245
           DATA    : inout STD_LOGIC_VECTOR (7  downto 0);  -- Datos de entrada/salida de FT245
           RXFn    : in    STD_LOGIC;
           TXEn    : in    STD_LOGIC;
           RDn     : out   STD_LOGIC;
           WRn     : out   STD_LOGIC;
           OEn     : out   STD_LOGIC;                       -- No se usa en el modo FT245 As�ncrono.
           SIWUn   : out   STD_LOGIC;                       -- Si se conecta, debe estar fijado a HIGH.
           CLKOUT  : in    STD_LOGIC;                       -- No se usa en el modo FT245 As�ncrono.
           PWRSAVn : out   STD_LOGIC;                       -- Si se conecta, debe estar fijado a HIGH.
           
           -- MT9V111
           CAMERA  : in    STD_LOGIC_VECTOR (7 downto 0);   -- Datos provenientes de la c�mara.
           PCLK    : in    STD_LOGIC;                       -- Referencia de reloj para datos recibidos (p�xeles).
           VSYNC   : in    STD_LOGIC;                       -- Referencia de inicio de transmisi�n de la im�gen.
           HREF    : in    STD_LOGIC;                       -- Referencia de inicio de transmisi�n de la fila. 
           XCLK    : out   STD_LOGIC;                       -- Referencia de reloj hacia la c�mara.
           RSTn    : out   STD_LOGIC;                       -- Reset de la c�mara.
           SDA     : out   STD_LOGIC;                       -- Interfaz de configuraci�n de la c�mara - Datos.
           SCL     : out   STD_LOGIC                        -- Interfaz de comunicaci�n de la c�mara  - Reloj.
           );
end TOP;

architecture Behavioural of TOP is

    -- Declaraci�n MMCM.
    component clk_wiz_0
    port
     (
          -- Clock out ports
          clk_out1          : out    std_logic;  -- Salida de reloj.
          clk_out2          : out    std_logic;  -- Salida de reloj.
          -- Status and control signals
          reset             : in     std_logic;  -- Se�al de reset.
          locked            : out    std_logic;  -- Flag de indicaci�n de la estabilidad.
          -- Clock in ports
          clk_in1           : in     std_logic   -- Entraada del oscilador.
     );
    end component;

    -- Se�ales MMCM.
    signal MCLK    : STD_LOGIC;           -- Se�al de reloj a 100 MHz.
    signal PIXCLK  : STD_LOGIC;           -- Se�al de reloj de c�mara a 12 MHz
    signal LOCKED  : STD_LOGIC;           -- Indica que la se�al de reloj es estable.
    alias  CLK_RST : STD_LOGIC is BTN(0); -- La se�al de reset del reloj se genera con el bot�n central.
    signal RST     : STD_LOGIC;           -- Se�al de reset generada a partir de LOCKED.

    -- Se�ales display.
    signal DDi : STD_LOGIC_VECTOR (15 downto 0);
    signal DPi : STD_LOGIC_VECTOR (3 downto 0);
    
    -- Se�ales FT245.
    signal VALUE_RX, VALUE_TX : STD_LOGIC_VECTOR (7 downto 0);
    signal RX_EMPTY, TX_EMPTY : STD_LOGIC;
    signal PUSH_TX, POP_RX    : STD_LOGIC;
    signal FT245_MODE         : STD_LOGIC;
    
    -- Se�ales FSM.
    signal FRAME_REQUEST : STD_LOGIC;
    
    -- Se�ales c�mara.
    signal FRAME_END : STD_LOGIC;
begin

    -- MODULOS
    
    ----- MMCM -----
    miMMCM : clk_wiz_0
    port map ( 
        -- Clock in ports
        clk_in1  => CLK,      -- Se�al de reloj del oscilador.
        
        -- Clock out ports  
        clk_out1 => MCLK,     -- Reloj maestro   a 100 MHz.
        clk_out2 => PIXCLK,   -- Reloj de c�mara a 12 MHz.
        
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
           DATA_rx  => VALUE_RX,              -- Dato recibido.
           DATA_tx  => VALUE_TX,              -- Dato a transmitir
           
           -- Control 
           mode     => FT245_MODE,
           
           POP_RX   => POP_RX,
           RX_EMPTY => RX_EMPTY,
           
           PUSH_TX  => PUSH_TX,
           TX_EMPTY => TX_EMPTY
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
           FIFO_RX_VALUE => VALUE_RX,
           
           -- Entradas de control de c�mara
           FRAME_END     => FRAME_END,
           
           -- Salidas de control de FT245.
           FT245_MODE    => FT245_MODE,
           FIFO_RX_POP   => POP_RX,
           
           -- Salidas de control de c�mara.
           REQUEST_IMAGE => FRAME_REQUEST
    );
    
    ----- END Instancia M�dulo de control -----
    
    ----- Instancia m�dulo c�mara -----
    
     CAMERA_inst: entity work.camera
     port map(
      CLK           => MCLK,
      reset         => RST,
      -- Inputs from camera ------------------
      DATA_IN       => CAMERA,        -- i [7:0]
      FRAME_VALID   => VSYNC,         -- i
      LINE_VALID    => HREF,          -- i
      PIXCLK        => PCLK,          -- i
      -- Inputs from FPGA --------------------
      IMAGE_REQUEST => FRAME_REQUEST, -- i
      -- Outputs to FPGA ---------------------
      DATA_OUT      => VALUE_TX,      -- o [7:0]
      DATA_READY    => PUSH_TX,       -- o
      FRAME_END     => FRAME_END      -- o
     );
    
    ----- END Instancia m�dulo c�mara -----
    
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
    
    -- FT245
    OEn <= '1';
    PWRSAVn <= '1';
    SIWUn   <= '1';
    
    -- Camera
    XCLK <= PIXCLK;
    RSTn <= not RST;
    SDA  <= '0';
    SCL  <= '0';
    
    -- LED
    LED <= (others => '0');
    
    -- Display
    DDi(15 downto 0) <= (others => '0'); 
    DPi <= (others => '1');
    
    ----- END Asignaci�n de salidas -----
    
    
end Behavioural;
