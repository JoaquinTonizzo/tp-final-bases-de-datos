drop table if exists alumne;
drop table if exists materia;
drop table if exists correlatividad;
drop table if exists comision;
drop table if exists cursada;
drop table if exists periodo;
drop table if exists historia_academica;
drop table if exists error;
drop table if exists envio_email;
drop table if exists entrada_trx;


create table alumne (
    id_alumne int,
    nombre text,
    apellido text,
    dni int,
    fecha_nacimento date,
    telefono char(12),
    email text
);

create table materia (
    id_materia int,
    nombre text
);

create table correlatividad (
    id_materia int,
    id_mat_correlativa int
);

create table comision (
    id_materia int,
    id_comision int,
    cupo int
);

create table cursada (
    id_materia int,
    id_alumne int,
    id_comision int,
    f_inscripcion timestamp,
    nota int,
    estado char(12)
);

create table periodo (
    semestre text,
    estado char(15)
);

create table historia_academica (
    id_alumne int,
    semestre text,
    id_materia int,
    id_comision int,
    estado char(15),
    nota_regular int,
    nota_final int
);

create table error (
    id_error serial,
    operacion char(15),
    semestre text,
    id_alumne int,
    id_materia int,
    id_comision int,
    f_error timestamp,
    motivo varchar(80)
);

create table envio_email (
    id_email serial,
    f_generacion timestamp,
    email_alumne text,
    asunto text,
    cuerpo text,
    f_envio timestamp,
    estado char(10)
);

create table entrada_trx (
    id_orden int,
    operacion char(15),
    año int,
    nro_semestre int,
    id_alumne int,
    id_materia int,
    id_comision int,
    nota int
);
