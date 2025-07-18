--------------------------------------------------------------------------------
--  Autor:       Christian Diego Cobos Marcos
--  DNI:         77438323Z
--  Fecha:       16/07/2025
--  Curso:       MSEEI 2024-2025
--  Descripción: ViCON - FIFO memory
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

entity FIFO is
    Generic (
              B : NATURAL := 2; -- Anchura de bus de direcciones.
              W : NATURAL := 8  -- Anchura de los buses de datos.
             );
             
    -- Interfaz E/S de FIFO
    Port ( CLK   : in  STD_LOGIC;                        -- Señal de reloj.
           RST   : in  STD_LOGIC;                        -- Flag reset.
           DIN   : in  STD_LOGIC_VECTOR (W-1 DOWNTO 0);  -- Dato de entrada (ancho de palabra W).
           PUSH  : in  STD_LOGIC;                        -- Flag de introducción de dato.
           FULL  : out STD_LOGIC;                        -- Indica FIFO llena.
           DOUT  : out STD_LOGIC_VECTOR (W-1 DOWNTO 0);  -- Dato de salida (ancho de palabra W).
           POP   : in  STD_LOGIC;                        -- Flag de retirada de dato.
           EMPTY : out STD_LOGIC);                       -- Indica FIFO vacía.
end FIFO;

architecture Behavioral of FIFO is

    -- Lógica de estado --
    signal is_full   : STD_LOGIC;                    -- Flag de FIFO llena.
    signal is_empty  : STD_LOGIC;                    -- Flag de FIFO vacía.
    signal occupancy : NATURAL range 0 to 2**B := 0; -- Contador de ocupación de la memoria.
    -- END Lógica de estado --

    -- Lógica de control --
    signal wr_ptr    : UNSIGNED(B-1 DOWNTO 0) := (others => '0'); -- Puntero de escritura. Inicializado a 0 para comenzar cuenta.
    signal rd_ptr    : UNSIGNED(B-1 DOWNTO 0) := (others => '0'); -- Puntero de lectura. Inicializado a 0 para comenzar cuenta.
    -- END Lógica de control --

    -- LUTRAM --
    type ram_type is array (2**B-1 DOWNTO 0) of STD_LOGIC_VECTOR (W-1 DOWNTO 0);
    signal ram_name  : ram_type;                                  -- Array de memoria.
    signal wr_en     : STD_LOGIC;                                 -- Habilitación de escritura.
    signal rd_en     : STD_LOGIC;                                 -- Habilitación de lectura.
    -- END LUTRAM --

begin

    ----- LUTRAM -----
    
    process (CLK)
    begin
        if rising_edge(clk) then
            if wr_en = '1' then -- Puerto de escritura.
                ram_name(to_integer(wr_ptr)) <= DIN;
            end if;
        end if;
    end process;
    
    -- Puerto de lectura.
    DOUT <= ram_name(to_integer(rd_ptr));
    
    ----- END LUTRAM -----

    ----- Lógica de control -----
    
    -- Lógica de habilitación.
    wr_en <= (PUSH and not is_full) or (PUSH and POP and is_full); -- Habilitación escritura.
    rd_en <= POP and not is_empty;                                 -- Habilitación lectura.
    
    -- Puntero de escritura.
    process
    begin
        wait until rising_edge(CLK);
        if RST = '1' then                                     -- Reset síncrono.
            wr_ptr <= to_unsigned(0, B);
        elsif wr_en = '1' then                                -- Actualización puntero escritura.
            wr_ptr <= unsigned(wr_ptr) + 1;
        end if;
    end process;
    
    --Puntero de lectura.
    process
    begin
        wait until rising_edge(CLK);
        if RST = '1' then                                     -- Reset síncrono.
            rd_ptr <= to_unsigned(0, B);
        elsif rd_en = '1' then                                -- Actualización puntero lectura.
            rd_ptr <= unsigned(rd_ptr) + 1;
        end if;
    end process;
    
    ----- END Lógica de control -----
    
    ----- Lógica de estado -----
    
    -- Contador UP/DOWN.
    process
    begin
        wait until rising_edge(CLK);
        if RST = '1' then               -- Reset síncrono.
            occupancy <= 0;
        elsif wr_en = '1' and rd_en = '0' then
            occupancy <= occupancy + 1; -- Aumento de contador con escritura.
        elsif rd_en = '1' and wr_en = '0' then
            occupancy <= occupancy - 1; -- Disminución del contador con lectura.
        end if;            
    end process;
    
    -- Lógica de estado lleno o vacío.
    is_empty <= '1' when occupancy = 0    else '0'; -- Flag de FIFO vacía.
    is_full  <= '1' when occupancy = 2**B else '0'; -- Flag de FIFO llena.
    
    -- Salidas de estado.
    FULL     <= is_full;                        
    EMPTY    <= is_empty;
    
    ----- END Lógica de estado -----

end Behavioral;
