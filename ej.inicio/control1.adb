 
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;


procedure control1 is
     
        type Tabla_sensores is array (1..8) of integer; 
        
        function Inicializar_dispositivos return integer;
        pragma Import (C, Inicializar_dispositivos,"Inicializar_dispositivos");
 
        procedure Leer_Sensores (sensores: out Tabla_sensores);
        pragma Import (C, Leer_Sensores, "Leer_Todos_Los_Sensores");

	function Leer_Sensor (pin: in integer) return integer;
        pragma Import (C, Leer_Sensor,"analogRead");

        function Leer_Pulsador return integer;
        pragma Import (C, Leer_Pulsador, "Leer_Pulsador");

	function Poner_Led_Rojo (Led_Rojo: in integer) return integer;
        pragma Import (C, Poner_Led_Rojo,"Poner_Led_Rojo");

	function Poner_Led_Verde (Led_verde: in integer) return integer;
        pragma Import (C, Poner_Led_Verde,"Poner_Led_Verde");

        function Sensor_infrarrojos return integer;
        pragma Import (C, Sensor_infrarrojos, "Sensor_infrarrojos"); 

        procedure Activar_trigger (Valor_Trig: in integer);
        pragma Import (C, Activar_trigger, "activa_trigger");

        function Leer_echo return integer;
        pragma Import (C, Leer_echo, "lee_echo"); 

        function Cerrar return integer;
        pragma Import (C, Cerrar,"Cerrar_Dispositivos");

        function Girar_Motor (giro: in integer) return integer;
        pragma Import (C, Girar_Motor,"Mover_Servo");
 
        -- Declare an Ada function spec for Get_Num, then use
        --  C function get_num for the implementation.
        -- function Get_Num return Integer;
        -- pragma Import (C, Get_Num, "get_num");
     
        -- Declare an Ada procedure spec for Print_Num, then use
        --  C function print_num for the implementation.
        -- procedure Print_Num (Num : Integer);
        -- pragma Import (C, Print_Num, "print_num")


       Valor, n : integer := 9;
       Valor_todos_sensores: Tabla_sensores;

    begin

       put_line ("Arranca programa principal");
       n := Inicializar_dispositivos;
       put ("Inicializados los dispositivos: "); put (n); New_line;

  -- Leemos sensor infrarojos y pulsador
       Valor := Sensor_infrarrojos;
       put ("Infrarrojos ="); put (Valor); New_Line;

       Valor := Leer_Pulsador;
       put ("Pulsador ="); put (Valor); New_Line;

       delay (0.3); -- Espera 300 milisegundos

  -- Leemos el convertidor A/D
       Valor := Leer_Sensor (0);
       put ("Sensor0 ="); put (Valor); New_Line;

       delay (0.3); -- Espera 300 milisegundos
      for i in 1.. 5 loop
         Leer_Sensores (Valor_todos_sensores);
         for j in 1 .. 8 loop
           put ("  Sen_"); Put(j,1); Put ("="); Put (Valor_todos_sensores(j),4); 
         end loop;
         New_Line;
         delay (0.3);
      end loop;

  -- Encedemos diodo
       put_line ("enciende luz roja"); 
       Valor := Poner_Led_Rojo (1);
       delay (0.5);
       Valor := Poner_Led_Rojo (0); 
       put_line ("apaga luz roja");

       put_line ("Finaliza el programa");

end control1;
