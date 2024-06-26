create or replace function probar_transacciones() returns void as $$
declare
	trx record;
begin
	for trx in select * from entrada_trx order by id_orden loop
		if trx.operacion = 'apertura' then 
			perform apertura_inscripcion(trx.año, trx.nro_semestre);
		elsif trx.operacion = 'alta inscrip' then 
			perform inscripcion_materia(trx.id_alumne, trx.id_materia, trx.id_comision);
		elsif trx.operacion = 'baja inscrip' then 
			perform baja_inscripcion(trx.id_alumne, trx.id_materia);
		elsif trx.operacion = 'cierre inscrip' then 
			perform cierre_inscripcion(trx.año, trx.nro_semestre);
		elsif trx.operacion = 'aplicacion cupo' then 
			perform aplicacion_de_cupos(trx.año, trx.nro_semestre);
		elsif trx.operacion = 'ingreso nota' then 
			perform ingreso_nota_cursada(trx.id_alumne, trx.id_materia, trx.id_comision, trx.nota);
		elsif trx.operacion = 'cierre cursada' then
			perform cierre_cursada(trx.id_materia, trx.id_comision);
		end if;
	end loop;
end;
$$ language plpgsql;
