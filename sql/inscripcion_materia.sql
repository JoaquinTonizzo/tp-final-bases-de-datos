create or replace function inscripcion_materia(id_alumne_input int, id_materia_input int, id_comision_input int) returns boolean as $$
declare
    correlatividad_no_cumple boolean;
begin
    if not exists (select 1 from periodo where estado = 'inscripcion') then
        insert into error (operacion, id_alumne, id_materia, id_comision, f_error, motivo)
					values ('alta inscrip', id_alumne_input, id_materia_input, id_comision_input, current_timestamp, '?período de inscripción cerrado.');
        return false;
    end if;

    if not exists (select 1 from alumne where id_alumne = id_alumne_input) then
        insert into error (operacion, id_alumne, id_materia, id_comision, f_error, motivo)
					values ('alta inscrip', id_alumne_input, id_materia_input, id_comision_input, current_timestamp, '?id de alumne no válido.');
        return false;
    end if;

    if not exists (select 1 from materia where id_materia = id_materia_input) then
        insert into error (operacion, id_alumne, id_materia, id_comision, f_error, motivo)
					values ('alta inscrip', id_alumne_input, id_materia_input, id_comision_input, current_timestamp, '?id de materia no válido.');
        return false;
    end if;

    if not exists (select 1 from comision where id_comision = id_comision_input and id_materia = id_materia_input) then
        insert into error (operacion, id_alumne, id_materia, id_comision, f_error, motivo)
					values ('alta inscrip', id_alumne_input, id_materia_input, id_comision_input, current_timestamp, '?id de comisión no válido para la materia.');
        return false;
    end if;

    if exists (select 1 from cursada where id_alumne = id_alumne_input and id_materia = id_materia_input) then
        insert into error (operacion, id_alumne, id_materia, id_comision, f_error, motivo)
					values ('alta inscrip', id_alumne_input, id_materia_input, id_comision_input, current_timestamp, '?alumne ya inscripte en la materia.');
        return false;
    end if;

    select exists (
        select 1 from correlatividad c where c.id_materia = id_materia_input and not exists (
            select 1 from historia_academica h
						where h.id_alumne = id_alumne_input and h.id_materia = c.id_mat_correlativa and (h.estado = 'regular' or h.estado = 'aprobada'))) 
    into correlatividad_no_cumple;

    if correlatividad_no_cumple then
        insert into error (operacion, id_alumne, id_materia, id_comision, f_error, motivo)
					values ('alta inscrip', id_alumne_input, id_materia_input, id_comision_input, current_timestamp, '?alumne no cumple requisitos de correlatividad.');
        return false;
    end if;

    insert into cursada values (id_materia_input, id_alumne_input, id_comision_input, current_timestamp, null, 'ingresade');
    return true;
end;
$$ language plpgsql;
