----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/20/2025 11:19:44 AM
-- Design Name: 
-- Module Name: camera - Behavioral
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

entity camera is
--  Port ( );
end camera;

architecture Behavioral of camera is

begin


end Behavioral;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/19/2025 06:06:14 PM
-- Design Name: 
-- Module Name: camera - Behavioral
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

entity camera is
  Port ( 
        CLK         : in    STD_LOGIC;                        -- Señal de reloj interna de la FPGA
        reset       : in    STD_LOGIC;                        -- Señal de reset
        
        -- Inputs from camera
        DATA_IN     : in    STD_LOGIC_VECTOR(7 downto 0);     -- Vector de datos de entrada de la cámara
        FRAME_VALID : in    STD_LOGIC;                        -- Flag de inicio/fin de frame
        LINE_VALID  : in    STD_LOGIC;                        -- Flag de inicio/fin de línea
        PIXCLK      : in    STD_LOGIC;                        -- Reloj de muestreo de las imágenes.
        
        
        -- Outputs to camera
        OUTCLK      : out   STD_LOGIC;                        -- Reloj de cámara.
        SCLK        : out   STD_LOGIC;                        -- Reloj de comunicación serie.
        SDATA       : inout STD_LOGIC;                        -- Datos de comunicación serie.
        SADDR       : out   STD_LOGIC;                        -- Dirección de comunicación serie.
        STANDBY     : out   STD_LOGIC;                        -- Control de modo de bajo consumo.
        OEn         : out   STD_LOGIC;                        -- Control de triestado de pines de salida de la cámara.
        
        
        -- Inputs from FPGA.
        
        -- Outputs to FPGA.
        DATA_OUT   : out   STD_LOGIC_VECTOR(7 downto 0);     -- Vector de datos de salida de la cámara
        DATA_READY : out   STD_LOGIC                         -- Flag de dato disponible
  );
end camera;

architecture Behavioral of camera is

begin


end Behavioral;
