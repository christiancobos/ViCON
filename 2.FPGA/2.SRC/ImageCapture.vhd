----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/20/2025 06:01:25 PM
-- Design Name: 
-- Module Name: ImageCapture - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ImageCapture is
  Port ( 
        CLK         : in    STD_LOGIC;                        -- Señal de reloj interna de la FPGA
        reset       : in    STD_LOGIC;                        -- Señal de reset
        
        -- Inputs from camera
        DATA_IN     : in    STD_LOGIC_VECTOR(7 downto 0);     -- Vector de datos de entrada de la cámara
        FRAME_VALID : in    STD_LOGIC;                        -- Flag de inicio/fin de frame
        LINE_VALID  : in    STD_LOGIC;                        -- Flag de inicio/fin de línea
        PIXCLK      : in    STD_LOGIC;                        -- Reloj de muestreo de las imágenes.
        
        -- Outputs to FPGA.
        DATA_OUT   : out   STD_LOGIC_VECTOR(7 downto 0);     -- Vector de datos de salida de la cámara
        DATA_READY : out   STD_LOGIC                         -- Flag de dato disponible
        
  );
end ImageCapture;

architecture Behavioral of ImageCapture is

        -- Señales para el sincronizador.
        signal line_reg  : STD_LOGIC_VECTOR (1 downto 0);
        signal frame_reg : STD_LOGIC_VECTOR (1 downto 0);
        
        alias LINE_VALID_REG  : STD_LOGIC is line_reg(0);
        alias FRAME_VALID_REG : STD_LOGIC is frame_reg(0);

        -- Señales de la máquina de estados.
        type STATES is (IDLE, WAIT_FOR_LINE, LINE_READ);
        signal state_reg, state_next : STATES;
        
        -- Señales para la captura de datos.
        signal send_enable_reg, send_enable_next : STD_LOGIC;


begin
    ----- Sincronizador -----
    
    process(CLK, reset)
    begin
        if reset = '1' then                          -- Reset asíncrono
            -- Inicializa con todos 0s
            line_reg  <= (others => '0');            
            frame_reg <= (others => '0');  
        elsif rising_edge(CLK) then                  -- Flanco de subida del reloj
            -- Desplazamiento de señales
            line_reg  <= LINE_VALID & line_reg(1);   
            frame_reg <= FRAME_VALID & frame_reg(1);
        end if;
    end process;
    
    ----- END Sincronizador -----

    ----- State register. -----
    
    process (CLK, reset)
    begin 
        if reset = '1' then
            state_reg <= IDLE;
        elsif CLK'event and CLK='1' then
            state_reg <= state_next;
        end if;
    
    end process;
    
    ----- END State register. -----

    ----- Máquina de estados de lectura. -----

    process (CLK, state_reg, LINE_VALID_REG, FRAME_VALID_REG)
    begin
    
        case state_reg is
        
            when IDLE =>
                if FRAME_VALID_REG = '1' then
                    state_next <= WAIT_FOR_LINE;
                end if;
            
            when WAIT_FOR_LINE =>
                if LINE_VALID_REG = '1' then
                    state_next <= LINE_READ;
                elsif FRAME_VALID_REG = '0' then
                    state_next <= IDLE;
                end if;
                
            when LINE_READ =>
                
                if LINE_VALID_REG = '0' then
                    state_next <= WAIT_FOR_LINE;
                end if;
            
        end case;
    
    
    
    end process;
    
    ----- END Maquina de estados de lectura. -----


end Behavioral;
