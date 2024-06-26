create or replace function cierre_inscripcion(año_input int, semestre_input int) returns boolean as $$
declare
    periodo_estado text;
begin
    select estado into periodo_estado from periodo where semestre = año_input || '-' || semestre_input;

    if not found or periodo_estado != 'inscripcion' then
        insert into error (operacion, semestre, f_error, motivo)
					values ('cierre inscrip', año_input || '-' || semestre_input, current_timestamp, '?el semestre no se encuentra en período de inscripción.');
        return false;
    end if;

    update periodo set estado = 'cierre inscrip' where semestre = año_input || '-' || semestre_input;
    
    return true;
end;
$$ language plpgsql;


