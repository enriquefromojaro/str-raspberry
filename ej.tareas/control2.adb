 
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;


procedure control2 is
------------------------ Objetos protegidos --------------------------
       Protected Sintomas is
	   function ReadVolante return integer;
	   procedure WriteVolante (Val : Integer);
	   function ReadRelax return boolean;
	   procedure WriteRelax (Val : Boolean);
       private
          Shared_Volante : integer := 0;
          Shared_Relax: boolean := false;
       end Sintomas;

       Protected body Sintomas is
           function ReadVolante return integer is
               begin
                    return Shared_Volante;
               end ReadVolante;
            procedure WriteVolante (Val : integer) is
               begin
                    Shared_Volante:= Val;
               end WriteVolante;
           function ReadRelax return boolean is
               begin
                    return Shared_Relax;
               end ReadRelax;
            procedure WriteRelax (Val : boolean) is
               begin
                    Shared_Relax:= Val;
               end WriteRelax;
       end Sintomas;

--------------------------Funciones------------------------------------     
        --  Declare then export an Integer entity called num_from_Ada
        n : Integer := 7;
 
        type Tabla_sensores is array (1..8) of integer; 
        --sensores: Tabla_sensores;
        
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

	function Sensor_Volante return integer is
		begin
			return Leer_Sensor(2);
		end Sensor_Volante;
	function Sensor_Temp return integer is
		begin
			return Leer_Sensor(0);
		end Sensor_Temp;
	function Sensor_Luz return integer is
		begin
			return Leer_Sensor(1);
		end Sensor_Luz;
	function Sensor_Agarre return boolean is
		begin
			return Sensor_infrarrojos = 0;
		end Sensor_Agarre;

  procedure Lanza_Tareas;  
   
  procedure Lanza_Tareas is
    task deteccionVolantazo;
    task deteccionAgarre; 

    task body deteccionVolantazo is
       vActual, vAnterior, diff : integer := 0;
       siguienteInst : Time;
       intervalo : Time_Span := Milliseconds(400);
	
      begin
	 vAnterior := Sensor_Volante;
	 siguienteInst := Clock + intervalo; 
         loop
	   put("Volante: ");
	   vActual := Sensor_Volante;
	   diff := abs(vActual - vAnterior);
	   put("Diferencia: ");
           put(diff);
	   vAnterior :=vActual;
	   Sintomas.WriteVolante(diff);
           delay until siguienteInst;
           siguienteInst := siguienteInst + intervalo;
         end loop;
      end deteccionVolantazo;

     task body deteccionAgarre is
       vActual, vAnterior: Boolean := false;
       siguienteInst : Time;
       intervalo : Time_Span := Milliseconds(400);
       contadorAgarre : Integer := 0;
       sintoma : Boolean := false;
	
      begin
	 vAnterior:= Sensor_Agarre;
	 vActual := vActual;
	 siguienteInst := Clock + intervalo; 
         loop
	   put("Agarre volante: ");
	   vAnterior:= vActual;
	   vAnterior:= Sensor_Agarre;
	   -- SIN AGARRAR
	   if vActual then
		if contadorAgarre < 3 then
			contadorAgarre := contadorAgarre + 1;
			if contadorAgarre = 3 and sintoma = false then
				sintoma := true;
				Sintomas.WriteRelax(sintoma);
				put("Detectado relax al volante!!");
			end if;
		end if;
	   else
	   -- AGARRADO
		if sintoma then
			contadorAgarre := contadorAgarre - 1;
			if contadorAgarre = 1 then
				sintoma := false;
				Sintomas.WriteRelax(sintoma);
				contadorAgarre := 0;
				put("Desactivado relax al volante. Vuelves a estar despierto!!");
			end if;	
		else
			contadorAgarre := 0;
		end if;
	   end if;

           delay until siguienteInst;
           siguienteInst := siguienteInst + intervalo;
         end loop;
      end deteccionAgarre; 

  begin 
     Put_Line ("Cuerpo del procedimiento Lanza_Tareas ");
  end Lanza_Tareas;
     
begin
    put_line ("Aaranca programa principal");
    n := Inicializar_dispositivos;
    put ("Inicializados los dispositivos: "); put (n, 3); New_line;
    Lanza_Tareas;
end control2;
