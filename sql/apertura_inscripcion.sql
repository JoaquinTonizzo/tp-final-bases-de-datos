create or replace function apertura_inscripcion(año_input int, semestre_input int) returns boolean as $$
declare
    estado_periodo char(15);
    semestre_periodo text;
begin
    if año_input < extract(year from current_date) then
        insert into error (operacion, semestre, f_error, motivo)
					values ('apertura', año_input || '-' || semestre_input, current_timestamp, '?no se permiten inscripciones para un período anterior.');
        return false;
    end if;

    if semestre_input != 1 and semestre_input != 2 then
        insert into error (operacion, semestre, f_error, motivo)
					values ('apertura', año_input || '-' || semestre_input, current_timestamp, '?número de semestre no válido.');
        return false;
    end if;


    select estado into estado_periodo from periodo where semestre = año_input || '-' || semestre_input;
    if found and estado_periodo != 'cierre inscrip' then
        insert into error (operacion, semestre, f_error, motivo)
					values ('apertura', año_input || '-' || semestre_input, current_timestamp, '?no es posible reabrir la inscripción del período, estado actual: ' || estado_periodo);
        return false;
    end if;

    select semestre into semestre_periodo from periodo where (estado = 'inscripcion' or estado = 'cierre inscrip') and (semestre != año_input || '-' || semestre_input);
    if found then
        insert into error (operacion, semestre, f_error, motivo)
					values ('apertura', año_input || '-' || semestre_input, current_timestamp, '?no es posible abrir otro período de inscripción, período actual: ' || semestre_periodo);
        return false;
    end if;

    insert into periodo values (año_input || '-' || semestre_input, 'inscripcion')
    on conflict (semestre) do update set estado = 'inscripcion';
    return true;
end;
$$ language plpgsql;
