create or replace function ingreso_nota_cursada(id_alumne_i int, id_materia_i int, id_comision_i int, nota_i numeric) returns boolean as $$
declare

begin
	if not exists (select 1 from periodo where estado = 'cursada') then
        insert into error (operacion, id_alumne, id_materia, id_comision, f_error, motivo)
					values ('ingreso nota', id_alumne_i, id_materia_i, id_comision_i, current_timestamp, '?período de cursada cerrado.');
        return false;
	end if;

	if not exists (select 1 from alumne where id_alumne = id_alumne_i) then
		insert into error (operacion, id_alumne, id_materia, id_comision, f_error, motivo)
					values ('ingreso nota', id_alumne_i, id_materia_i, id_comision_i, current_timestamp, '?id de alumne no válido.');
        return false;
	end if;
	
	if not exists (select 1 from materia where id_materia = id_materia_i) then
        insert into error (operacion, id_alumne, id_materia, id_comision, f_error, motivo)
					values ('ingreso nota', id_alumne_i, id_materia_i, id_comision_i, current_timestamp, '?id de materia no válido.');
        return false;    
    end if;
    
    if not exists (select 1 from comision where id_comision = id_comision_i and id_materia = id_materia_i) then
        insert into error (operacion, id_alumne, id_materia, id_comision, f_error, motivo)
					values ('ingreso nota', id_alumne_i, id_materia_i, id_comision_i, current_timestamp, '?id de comisión no válido para la materia.');
        return false;
    end if;
	
	if not exists (select 1 from cursada where id_alumne=id_alumne_i and id_materia=id_materia_i and id_comision = id_comision_i and estado='aceptade') then
        insert into error (operacion, id_alumne, id_materia, id_comision, f_error, motivo)
					values ('ingreso nota', id_alumne_i, id_materia_i, id_comision_i, current_timestamp, '?alumne no cursa en la comision');
        return false;
    end if;	
	
	if nota_i < 0 or nota_i > 10 then 
	    insert into error (operacion, id_alumne, id_materia, id_comision, f_error, motivo)
					values ('ingreso nota', id_alumne_i, id_materia_i, id_comision_i, current_timestamp, '?nota no valida: ' || nota_i);
        return false;
    end if;	
	
	update cursada set nota = nota_i where id_alumne = id_alumne_i and id_materia = id_materia_i and id_comision = id_comision_i;    
	
	return true;
end;
$$ language plpgsql;
