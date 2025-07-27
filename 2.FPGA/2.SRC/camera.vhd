--------------------------------------------------------------------------------
--  Autor:       Christian Diego Cobos Marcos
--  DNI:         77438323Z
--  Fecha:       16/07/2025
--  Curso:       MSEEI 2024-2025
--  Descripción: ViCON - MT9V111 camera control
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- INSTANCE TEMPLATE -----------------------------------------------------------
--------------------------------------------------------------------------------
-- CAMERA_inst: entity work.camera
-- port map(
--  CLK           => MCLK,
--  reset         => RST,
--  -- Inputs from camera ------------------
--  DATA_IN       => ,       -- i [7:0]
--  FRAME_VALID   => ,       -- i
--  LINE_VALID    => ,       -- i
--  PIXCLK        => ,       -- i
--  -- Inputs from FPGA --------------------
--  IMAGE_REQUEST => ,       -- i
--  -- Outputs to FPGA ---------------------
--  DATA_OUT      => ,       -- o [7:0]
--  DATA_READY    => ,       -- o
--  FRAME_END     =>         -- o
-- );


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity camera is
  Port ( 
        CLK         : in    STD_LOGIC;                        -- Señal de reloj interna de la FPGA. (Master Clock)
        reset       : in    STD_LOGIC;                        -- Señal de reset.
        
        -- Inputs from camera
        DATA_IN     : in    STD_LOGIC_VECTOR(7 downto 0);     -- Vector de datos de entrada de la cámara
        FRAME_VALID : in    STD_LOGIC;                        -- Flag de inicio/fin de frame
        LINE_VALID  : in    STD_LOGIC;                        -- Flag de inicio/fin de línea
        PIXCLK      : in    STD_LOGIC;                        -- Reloj de muestreo de las imágenes.
        
        
        -- Inputs from FPGA.
        IMAGE_REQUEST : in STD_LOGIC;                         -- Solicitud de imagen desde el PC.
        
        -- Outputs to FPGA.
        DATA_OUT   : out   STD_LOGIC_VECTOR(7 downto 0);      -- Vector de datos de salida de la cámara
        DATA_READY : out   STD_LOGIC;                         -- Flag de dato disponible
        FRAME_END  : out   STD_LOGIC                          -- Flag de final de frame.
  );
end camera;

architecture Behavioral of camera is

    -- Señales para el sincronizador.
    signal line_reg   : STD_LOGIC_VECTOR (1  downto 0);
    signal frame_reg  : STD_LOGIC_VECTOR (1  downto 0);
    signal data_regs  : STD_LOGIC_VECTOR (15 downto 0);
    signal pixclk_reg : STD_LOGIC_VECTOR (1  downto 0);
    
    alias LINE_VALID_REG  : STD_LOGIC is line_reg(0);
    alias FRAME_VALID_REG : STD_LOGIC is frame_reg(0);
    alias DATA_REG        : STD_LOGIC_VECTOR(7 downto 0) is data_regs(7 downto 0);
    alias PCLK_REG        : STD_LOGIC is pixclk_reg(0);

    -- Señales de la máquina de estados.
    type STATES is (IDLE, WAIT_FOR_IMAGE, WAIT_FOR_FRAME, WAIT_FOR_LINE, WAIT_FOR_DATA, DATA_SEND, SEND_STOP);
    signal state_reg, state_next : STATES;
    
    -- Señales para la captura de datos.
    signal send_enable_reg, send_enable_next : STD_LOGIC;
    signal frame_end_reg, frame_end_next     : STD_LOGIC;

begin
    
    ----- Sincronizador -----
    
    process(CLK, reset)
    begin
        if reset = '1' then                          -- Reset asíncrono
            -- Inicializa con todos 0s
            line_reg   <= (others => '0');            
            frame_reg  <= (others => '0');  
            data_regs  <= (others => '0');
            pixclk_reg <= (others => '0');
            
        elsif rising_edge(CLK) then                  -- Flanco de subida del reloj
            -- Desplazamiento de señales
            line_reg   <= LINE_VALID & line_reg(1);   
            frame_reg  <= FRAME_VALID & frame_reg(1);
            data_regs  <= DATA_IN & data_regs(15 downto 8);
            pixclk_reg <= PIXCLK & pixclk_reg(1); 
        end if;
    end process;
    
    ----- END Sincronizador -----

    -- TODO: Incluir registros extra.
    ----- State register. -----
    
    process (CLK, reset)
    begin 
        if reset = '1' then
            state_reg       <= IDLE;
            send_enable_reg <= '0';
            frame_end_reg   <= '0';
        elsif CLK'event and CLK='1' then
            state_reg       <= state_next;
            send_enable_reg <= send_enable_next;
            frame_end_reg   <= frame_end_next;
        end if;
    
    end process;
    
    ----- END State register. -----

    ----- Máquina de estados de lectura. -----

    process (state_reg, LINE_VALID_REG, FRAME_VALID_REG, PCLK_REG, IMAGE_REQUEST)
    begin
        -- Asignaciones por defecto.
        state_next       <= state_reg;
        send_enable_next <= '0';
        frame_end_next   <= '0';
    
        case state_reg is
        
            when IDLE =>
                if IMAGE_REQUEST = '1' then
                    if FRAME_VALID_REG = '0' then
                        state_next <= WAIT_FOR_FRAME;
                    else
                        state_next <= WAIT_FOR_IMAGE;
                    end if;
                end if;
            
            when WAIT_FOR_IMAGE => 
                if  FRAME_VALID_REG = '0' then
                    state_next <= WAIT_FOR_FRAME;
                end if;
                
            when WAIT_FOR_FRAME =>
                if  FRAME_VALID_REG = '1' then
                    state_next <= WAIT_FOR_LINE;
                end if; 
            
            when WAIT_FOR_LINE =>
                if LINE_VALID_REG = '1' then
                    state_next <= WAIT_FOR_DATA;
                elsif FRAME_VALID_REG = '0' then
                    state_next <= IDLE;
                    frame_end_next <= '1';
                end if;
                
            when WAIT_FOR_DATA =>
                
                if LINE_VALID_REG = '0' then
                    state_next <= WAIT_FOR_LINE;
                elsif PCLK_REG = '1' then
                    state_next <= DATA_SEND;
                end if;
                
            when DATA_SEND =>
                send_enable_next <= '1';
                state_next       <= SEND_STOP;
                
            when SEND_STOP =>
                if PCLK_REG = '0' then
                    state_next <= WAIT_FOR_DATA;
                end if;
                
            when others =>
                state_next       <= IDLE;
                send_enable_next <= '0';
            
        end case;
    
    
    
    end process;
    
    ----- END Maquina de estados de lectura. -----
    
    ----- Conexión de salidas -----
    
    DATA_OUT   <= DATA_REG;
    DATA_READY <= send_enable_reg;
    FRAME_END  <= frame_end_reg;
    
    ----- END Conexión de salidas -----

end Behavioral;
