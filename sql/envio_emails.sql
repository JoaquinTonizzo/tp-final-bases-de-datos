--tigger para informar ingresade
create or replace function generar_email_alta_inscripcion() returns trigger as $$
declare
     a_email text;
     a_nombre text;
     a_apellido text; 
     materia_nombre text;
begin
   if new.estado = 'ingresade' then
     -- informacion del alumno y la materia
     select email, nombre, apellido into a_email, a_nombre, a_apellido
     from alumne
     where id_alumne = new.id_alumne;
     
     select nombre into materia_nombre
     from materia
     where id_materia = new.id_materia;
     
     --insertar en la tabla
     insert into envio_email (f_generacion, email_alumne, asunto, cuerpo, estado)
     values (
         current_timestamp,
         a_email,
         'Inscripcion registrada',
         'Hola ' || a_nombre || ' ' || a_apellido || ', su inscripcion en ' || materia_nombre || ' (Comision ' || new.id_comision || ') ha sido registrada exitosamente.', 
         'pendiente'
     );
   end if;
   return new;
end;
$$ language plpgsql;

create trigger trg_email_alta_inscripcion
after insert on cursada
for each row 
execute function generar_email_alta_inscripcion();

--tigger para informar dade de baja
create or replace function generar_email_baja_inscripcion() returns trigger as $$
declare
     a_email text;
     a_nombre text;
     a_apellido text; 
     materia_nombre text;
begin
	if new.estado = 'dade de baja' then
		select email, nombre, apellido into a_email, a_nombre, a_apellido
		from alumne
		where id_alumne = old.id_alumne;
     
		select nombre into materia_nombre
		from materia
		where id_materia = old.id_materia;
		
		insert into envio_email (f_generacion, email_alumne, asunto, cuerpo, estado)
		values(current_timestamp,
		a_email,
		'Inscripcion dada de baja',
		'Hola ' || a_nombre || ' ' || a_apellido || ', su inscripcion en ' || materia_nombre || ' (Comision ' || new.id_comision || ') ha sido dada de baja.', 
		'pendiente'
		);
	end if;
	return new;
end;
$$ language plpgsql;
 
create trigger trg_email_baja_inscripcion
after update of estado on cursada
for each row
when (old.estado != new.estado)
execute function generar_email_baja_inscripcion();
 
-- trigger para informar aceptade o en espera
create or replace function generar_email_estado_inscripcion() returns trigger as $$
declare 
     a_email text;
     a_nombre text;
     a_apellido text; 
     materia_nombre text;
begin
	select email, nombre, apellido into a_email, a_nombre, a_apellido
	from alumne
	where id_alumne = old.id_alumne;
    
	select nombre into materia_nombre
	from materia
	where id_materia = old.id_materia;

	if new.estado = 'aceptade' then
		insert into envio_email (f_generacion, email_alumne, asunto, cuerpo, estado)
		values(current_timestamp,
		a_email,
		'Inscripcion aceptada',
		'Hola ' || a_nombre || ' ' || a_apellido || ', su inscripcion en ' || materia_nombre || ' (Comision ' || new.id_comision || ') ha sido aceptada.', 
		'pendiente'
		);
	end if;
	
	if new.estado = 'en espera' then
		insert into envio_email (f_generacion, email_alumne, asunto, cuerpo, estado)
		values(current_timestamp,
		a_email,
		'Inscripcion en espera',
		'Hola ' || a_nombre || ' ' || a_apellido || ', su inscripcion en ' || materia_nombre || ' (Comision ' || new.id_comision || ') pasa a estado de espera.', 
		'pendiente'
		);
	end if;
	
	return new;
end;
  
$$ language plpgsql;

create trigger trg_email_estado_inscripcion
after update of estado on cursada 
for each row 
when (old.estado != new.estado)
execute function generar_email_estado_inscripcion();

--trigger para informar cierre de cursada
create or replace function generar_email_cierre_cursada() returns trigger as $$
declare
     a_email text;
     a_nombre text;
     a_apellido text; 
     materia_nombre text;
begin
	select email, nombre, apellido into a_email, a_nombre, a_apellido
	from alumne
	where id_alumne = new.id_alumne;
     
	select nombre into materia_nombre
	from materia
	where id_materia = new.id_materia;
       
    if new.estado = 'aprobada' then
		insert into envio_email(f_generacion, email_alumne, asunto, cuerpo, estado)
		values (current_timestamp, 
		a_email, 
		'Cierre de cursada',
		'Hola ' || a_nombre || ' ' || a_apellido || ', su cursada en la materia ' || materia_nombre || ' (Comision ' || new.id_comision || ') ha terminado. Estado: ' || new.estado || ', Nota Regular: '|| new.nota_regular||', Nota final: ' || new.nota_final, 
		'pendiente'
		);
	else 
		insert into envio_email(f_generacion, email_alumne, asunto, cuerpo, estado)
		values (current_timestamp, 
		a_email, 
		'Cierre de cursada',
		'Hola ' || a_nombre || ' ' || a_apellido || ', su cursada en la materia ' || materia_nombre || ' (Comision ' || new.id_comision || ') ha terminado. Estado: ' || new.estado || ',  Nota Regular: '|| new.nota_regular,
		'pendiente'
		);
	end if;
	
	return new;
end;
$$ language plpgsql; 

create trigger cierre_cursada_trigger
after insert on historia_academica
for each row
execute function generar_email_cierre_cursada();
         
         
     
   
