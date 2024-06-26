create or replace function aplicacion_de_cupos(numero_año int,numero_semestre int) returns boolean as $$
declare
	semestre_buscado text;
	comision_con_inscriptos record;
	fila record;
	cupo int;
begin
	semestre_buscado := numero_año || '-' || numero_semestre;

	if not exists (select 1 from periodo where semestre = semestre_buscado) then 
		insert into error (operacion, semestre, f_error, motivo)
					values ('aplicacion cupo', semestre_buscado, current_timestamp, '?el semestre no se encuentra en un período válido para aplicar cupos.');
		return false;
	end if;

	if exists (select 1 from periodo where semestre = semestre_buscado and estado != 'cierre inscrip') then 
		insert into error (operacion, semestre, f_error, motivo)
					values ('aplicacion cupo', semestre_buscado, current_timestamp, '?el semestre no se encuentra en un período válido para aplicar cupos.');
		return false;
	end if;

	for comision_con_inscriptos in select id_materia, id_comision from cursada group by id_materia, id_comision having count(distinct id_alumne) > 0 loop
		cupo := (select c.cupo from comision c  where c.id_materia = comision_con_inscriptos.id_materia and c.id_comision = comision_con_inscriptos.id_comision);	
		for fila in select * from cursada where id_materia = comision_con_inscriptos.id_materia and id_comision = comision_con_inscriptos.id_comision order by f_inscripcion loop
			if (fila.estado = 'ingresade') then
				if cupo > 0 then
					update cursada set estado = 'aceptade' where id_materia = fila.id_materia 
														   and id_alumne = fila.id_alumne 
														   and id_comision = fila.id_comision;
					cupo := cupo - 1;
				elsif cupo = 0 then
					update cursada set estado = 'en espera' where id_materia = fila.id_materia 
															and id_alumne = fila.id_alumne 
															and id_comision = fila.id_comision;
					
				end if;
			end if;
		end loop;
	end loop;		

	update periodo set estado = 'cursada' where estado = 'cierre inscrip';
			
	return true;
end;
$$ language plpgsql;



	
	



