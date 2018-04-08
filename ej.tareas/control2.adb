with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;

procedure control2 is
------------------------ Objetos protegidos --------------------------
       Protected Sintomas is
	   --Volante
       function ReadVolante return integer;
	   procedure WriteVolante (Val : Integer);
	   
       -- RElax
       function ReadRelax return boolean;
	   procedure WriteRelax (Val : Boolean);
	   
        --cabeza
       function ReadInclinacionCabeza return Integer;
	   procedure WriteInclinacionCabeza (Val : Integer);
	   
       --distancia
       function ReadDistancia return Integer;
	   procedure WriteDistancia (Val : Integer);

       private
          Shared_Volante : integer := 0;
          Shared_Relax: boolean := false;
          Shared_InclinacionCabeza: integer := 0;
          Shared_Distancia: integer := 0;
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
           function ReadInclinacionCabeza return integer is
               begin
                    return Shared_InclinacionCabeza;
               end ReadInclinacionCabeza;
            procedure WriteInclinacionCabeza (Val : integer) is
               begin
                    Shared_InclinacionCabeza:= Val;
               end WriteInclinacionCabeza;

            
           function ReadDistancia return integer is
               begin
                    return Shared_Distancia;
               end ReadDistancia;
            procedure WriteDistancia (Val : integer) is
               begin
                    Shared_Distancia:= Val;
               end WriteDistancia;

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
	function Sensor_Velocidad return integer is
		begin
			return Leer_Sensor(3);
		end Sensor_Velocidad;
	function Sensor_Distancia return integer is
        package E_S_REALES is new Float_IO (Float);
		Timeout : Time_Span := To_Time_Span(1.0); -- segundos
		Echo : integer := 0;
        Comienzo: Time;
        Periodo: Time_Span;
        Tiempo: float;

		begin
			Activar_trigger(1); 
			delay 0.15;	
			Activar_trigger(0); 
            Comienzo:= Clock;
			Select
			    delay To_Duration(Timeout);
		        put_line("Distancia infiniiiiiita");	
			then abort
                while Echo = 0 loop	
                    Echo :=	Leer_echo;
                end loop;
                Periodo := Clock - Comienzo;
                Tiempo := float(To_Duration(Periodo));
                put_line("El echo ha tardado ");
                E_S_REALES.Put(Tiempo,2,4,0); put_line("");
			end select;
	
			return 5; -- DISTANCIA FIJA (Nos faltan voltios)
		end Sensor_Distancia;

	function Detectar_Distraccion return integer is
        distancia : integer := 0;
        velocidad : integer := 0;
        relax: boolean := false;
        volanteDiff: integer := 0;
        dist_segura: boolean := false;
        volantazo: boolean := false;

		begin
            put_line("");
            put_line("=== TAREA::Detectar Distracción ===");

            distancia := Sintomas.ReadDistancia;
            velocidad := Sensor_Velocidad;
            relax := Sintomas.ReadRelax;
            volanteDiff := Sintomas.ReadVolante;

            put("Emergencia Distancia: ");
            put(distancia);
            put_line("");
            put("Emergencia Velocidad: ");
            put(velocidad);
            put_line("");
            put("Emergencia Relax: ");
            if relax then
                put("true");
                put_line("");
            else 
                put("false");
                put_line("");
            end if;
            put("Emergencia Volante diff: ");
            put(volanteDiff);
            put_line("");

            dist_segura := (distancia >= (velocidad/10)**2);
            volantazo := (velocidad > 70 and volanteDiff > 150);
            if (not dist_segura and volantazo) or ((not dist_segura or volantazo) and relax) then
                return 2;
            elsif (not dist_segura xor volantazo) then 
                return 1;
            end if;
			return 0;
		end Detectar_Distraccion;

  procedure Lanza_Tareas;  
   
  procedure Lanza_Tareas is
    task deteccionVolantazo;
    task deteccionAgarre; 
    task Emergencia;
    -- task deteccionInclinacionCabeza; 
    task deteccionDistancia;

    task body deteccionVolantazo is
       vActual, vAnterior, diff : integer := 0;
       siguienteInst : Time;
       intervalo : Time_Span := Milliseconds(400);
	
      begin
       put_line("");
	   put_line("=== TAREA::Detección Volantazo ===");

	   vAnterior := Sensor_Volante;
	   siguienteInst := Clock + intervalo; 
         loop
	        vActual := Sensor_Volante;
            diff := abs(vActual - vAnterior);
	        put("TDV::Diferencia: ");
            put(diff);
            put_line("");
	        vAnterior :=vActual;
	        Sintomas.WriteVolante(diff);
           delay until siguienteInst;
           siguienteInst := siguienteInst + intervalo;
         end loop;
      end deteccionVolantazo;

     task body deteccionAgarre is
       vActual, vAnterior: Boolean := false;
       siguienteInst : Time;
       intervalo : Time_Span := Milliseconds(500);
       contadorAgarre : Integer := 0;
       sintoma : Boolean := false;
	
      begin
        put_line("");
	    put_line("=== TAREA::Detección Relax ===");

	    vAnterior:= Sensor_Agarre;
        vActual := vActual;
	    siguienteInst := Clock + intervalo; 
         loop
           put_line("");
           put_line("TDR::Relax al volante: ");
           vAnterior:= vActual;
           vAnterior:= Sensor_Agarre;
           -- SIN AGARRAR
           if vActual then
              if contadorAgarre < 3 then
                contadorAgarre := contadorAgarre + 1;
                if contadorAgarre = 3 and sintoma = false then
                    sintoma := true;
                    Sintomas.WriteRelax(sintoma);
                    put_line("Detectado relax al volante!!");
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
				       put_line("Desactivado relax al volante. Vuelves a estar despierto!!");
			       end if;	
		        else
			      contadorAgarre := 0;
		        end if;
	        end if;
        put("TDR::Síntoma: ");
        if sintoma then
            put("true");
        else
            put("false");
        end if;
        put_line("");
           delay until siguienteInst;
           siguienteInst := siguienteInst + intervalo;
         end loop;
      end deteccionAgarre; 

    task body deteccionDistancia is
       distancia : integer := 0;
       siguienteInst : Time;
       intervalo : Time_Span := Milliseconds(300);
      begin
	      siguienteInst := Clock + intervalo; 
          loop
              distancia := Sensor_Distancia;
              put_line("TDD::Distancia: ");
              put(distancia);
              Sintomas.WriteDistancia(distancia);
              delay until siguienteInst;
              siguienteInst := siguienteInst + intervalo;
          end loop;
     end deteccionDistancia;

    task body Emergencia is
       velocidad : integer := 0;
       siguienteInst : Time;
       intervalo : Time_Span := Milliseconds(300);
       nivelDistraccion : integer := 0;
      begin
	    siguienteInst := Clock + intervalo; 
         loop
           put_line("");
           nivelDistraccion := Detectar_Distraccion; 
           put("TDE::Nivel Emergencia: ");
           put(nivelDistraccion);
           put_line("");
       
           delay until siguienteInst;
           siguienteInst := siguienteInst + intervalo;
         end loop;
      end Emergencia;

  begin 
     Put_Line ("Cuerpo del procedimiento Lanza_Tareas ");
  end Lanza_Tareas;
     
begin
    put_line ("Arranca programa principal");
    n := Inicializar_dispositivos;
    put_line ("Inicializados los dispositivos: "); put (n, 3); New_line;
    Lanza_Tareas;
end control2;
