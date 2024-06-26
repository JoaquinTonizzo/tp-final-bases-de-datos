create or replace function baja_inscripcion(id_alumne_input int, id_materia_input int) returns boolean as $$
declare
    periodo_estado text;
    cursada_obtenida cursada%rowtype;
begin
	if not exists (select 1 from periodo where (estado = 'inscripcion' or estado = 'cursada')) then
        insert into error (operacion, id_alumne, id_materia, f_error, motivo)
					values ('baja inscrip', id_alumne_input, id_materia_input, current_timestamp, '?no se permiten bajas en este período.');
        return false;
    end if;

    if not exists (select 1 from alumne where id_alumne = id_alumne_input) then
        insert into error (operacion, id_alumne, id_materia, f_error, motivo)
					values ('baja inscrip', id_alumne_input, id_materia_input, current_timestamp, '?id de alumne no válido.');
        return false;
	end if;

    if not exists (select 1 from materia where id_materia = id_materia_input) then
        insert into error (operacion, id_alumne, id_materia, f_error, motivo)
					values ('baja inscrip', id_alumne_input, id_materia_input, current_timestamp, '?id de materia no válido.');
        return false;
    end if;

    if not exists (select 1 from cursada where id_alumne = id_alumne_input and id_materia = id_materia_input and estado != 'dade de baja') then
        insert into error (operacion, id_alumne, id_materia, f_error, motivo)
					values ('baja inscrip', id_alumne_input, id_materia_input, current_timestamp, '?alumne no inscripte en la materia.');
        return false;
    end if;

    update cursada set estado = 'dade de baja' where id_alumne = id_alumne_input and id_materia = id_materia_input;

    select estado into periodo_estado from periodo where (estado = 'inscripcion' or estado = 'cursada');

    if periodo_estado = 'cursada' then
        select * into cursada_obtenida from cursada where id_materia = id_materia_input 
                                and estado = 'en espera' 
                                and id_comision = (select id_comision from cursada where id_alumne = id_alumne_input  and id_materia = id_materia_input)
                                order by f_inscripcion 
                                limit 1;

        if found then
            update cursada set estado = 'aceptade'
            where id_alumne = cursada_obtenida.id_alumne and id_materia = cursada_obtenida.id_materia;
        end if;
    end if;

    return true;
end;
$$ language plpgsql;
