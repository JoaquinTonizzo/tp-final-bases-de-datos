create or replace function cierre_cursada(p_id_materia int, p_id_comision int) returns boolean as $$
declare 
	semestre_periodo text;
	estado_cursada text;
	fila record;
begin 

		if not exists (select 1 from periodo where estado = 'cursada') then 
			insert into error (operacion, id_materia, id_comision, f_error, motivo)
						values ('cierre cursada', p_id_materia, p_id_comision, current_timestamp, '?periodo de cursada cerrado');
			return false;
		end if;    
		 
		if not exists (select 1 from materia where id_materia = p_id_materia) then 
			insert into error (operacion, id_materia, id_comision, f_error, motivo)
						values ('cierre cursada', p_id_materia, p_id_comision, current_timestamp, '?id de la materia no valido');
			return false;
		end if;
			
		if not exists (select 1 from comision where id_materia = p_id_materia and id_comision = p_id_comision) then 
			insert into error (operacion, id_materia, id_comision, f_error, motivo)
						values ('cierre cursada', p_id_materia, p_id_comision, current_timestamp, '?id de la comision no valido para la materia');
			return false;
		end if;

		if not exists (select 1 from cursada where id_materia = p_id_materia and id_comision = p_id_comision) then 
			insert into error (operacion, id_materia, id_comision, f_error, motivo)
						values ('cierre cursada', p_id_materia, p_id_comision, current_timestamp, '?comision sin alumnes inscriptes');
			return false;       
		end if;
		
		if exists (select 1 from cursada where id_materia = p_id_materia and id_comision = p_id_comision and estado = 'aceptade' and nota is null) then
			insert into error (operacion, id_materia, id_comision, f_error, motivo)
						values ('cierre cursada', p_id_materia, p_id_comision, current_timestamp, '?la carga de notas no esta completa');
			return false;       
		end if;
		
		select semestre into semestre_periodo from periodo where estado = 'cursada';
		
		for fila in select * from cursada where id_materia = p_id_materia and id_comision = p_id_comision and estado = 'aceptade' loop
			if fila.nota >= 7 and fila.nota <= 10 then
				estado_cursada := 'aprobada';
				insert into historia_academica values (fila.id_alumne, semestre_periodo, fila.id_materia, fila.id_comision, estado_cursada, fila.nota, fila.nota);
			elsif fila.nota >= 4 and fila.nota <7 then
				estado_cursada := 'regular';
				insert into historia_academica values (fila.id_alumne, semestre_periodo, fila.id_materia, fila.id_comision, estado_cursada, fila.nota, null);
			elsif fila.nota <= 3 and fila.nota>=1 then
				estado_cursada := 'reprobada';
				insert into historia_academica values (fila.id_alumne, semestre_periodo, fila.id_materia, fila.id_comision, estado_cursada, fila.nota, null);
			elsif  fila.nota = 0 then 
				estado_cursada := 'ausente';
				insert into historia_academica values (fila.id_alumne, semestre_periodo, fila.id_materia, fila.id_comision, estado_cursada, fila.nota, null);
			end if;
		end loop;
		
		delete from cursada where id_materia = p_id_materia and id_comision = p_id_comision;
		
    return true;
     	
end;
$$ language plpgsql;

