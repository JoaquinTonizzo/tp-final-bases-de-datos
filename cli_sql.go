package main

import (
	"fmt"
	"database/sql"
	_ "github.com/lib/pq"
	"log"
	"io/ioutil"
	"strings"
)

type entradaTrx struct {
	ID_orden	 int
	Operacion    string
	Año          sql.NullInt64
	Nro_semestre sql.NullInt64
	ID_alumne    sql.NullInt64
	ID_materia   sql.NullInt64
	ID_comision  sql.NullInt64
	Nota         sql.NullInt64
}

func ejecutarTesteo(db *sql.DB) error {	
	rows, err := db.Query(`select * from entrada_trx order by id_orden`)
	if err != nil {
		return err
	}
	defer rows.Close()

	var trx entradaTrx
	for rows.Next() {
		err := rows.Scan(&trx.ID_orden, &trx.Operacion, &trx.Año, &trx.Nro_semestre, &trx.ID_alumne, &trx.ID_materia, &trx.ID_comision, &trx.Nota)
		if err != nil {
			return err
		}
		
		trx.Operacion = strings.TrimSpace(trx.Operacion)
		switch trx.Operacion {
		case "apertura":
			tx, err := db.Begin()
			if err != nil {
				return err
			}		
			_, err = tx.Exec("select apertura_inscripcion($1, $2);", trx.Año, trx.Nro_semestre)
			if err != nil {
				tx.Rollback()
				return err
			}			
			err = tx.Commit()
			if err != nil {
				return err
			}
			
		case "alta inscrip":
			tx, err := db.Begin()
			if err != nil {
				return err
			}		
			_, err = tx.Exec("select inscripcion_materia($1, $2, $3);", trx.ID_alumne, trx.ID_materia, trx.ID_comision)
			if err != nil {
				tx.Rollback()
				return err
			}			
			err = tx.Commit()
			if err != nil {
				return err
			}
			
		case "baja inscrip":
			tx, err := db.Begin()
			if err != nil {
				return err
			}
			_, err = tx.Exec("select baja_inscripcion($1, $2);", trx.ID_alumne, trx.ID_materia)
			if err != nil {
				tx.Rollback()
				return err
			}	
			err = tx.Commit()
			if err != nil {
				return err
			}
			
		case "cierre inscrip":
			tx, err := db.Begin()
			if err != nil {
				return err
			}		
			_, err = tx.Exec("select cierre_inscripcion($1, $2);", trx.Año, trx.Nro_semestre)
			if err != nil {
				return err
			}		
			err = tx.Commit()
			if err != nil {
				return err
			}
			
		case "aplicacion cupo":
			tx, err := db.Begin()
			if err != nil {
				return err
			}
			_, err = tx.Exec("set transaction isolation level serializable")
			if err != nil {
				tx.Rollback()
				return err
			}
			_, err = tx.Exec("select aplicacion_de_cupos($1, $2);", trx.Año, trx.Nro_semestre)
			if err != nil {
				tx.Rollback()
				return err
			}
			err = tx.Commit()
			if err != nil {
				return err
			}
			
		case "ingreso nota":
			tx, err := db.Begin()
			if err != nil {
				return err
			}				
			_, err = tx.Exec("select ingreso_nota_cursada($1, $2, $3, $4);", trx.ID_alumne, trx.ID_materia, trx.ID_comision, trx.Nota)
			if err != nil {
				tx.Rollback()
				return err
			}
			err = tx.Commit()
			if err != nil {
				return err
			}
			
		case "cierre cursada":
			tx, err := db.Begin()
			if err != nil {
				return err
			}
			_, err = tx.Exec("set transaction isolation level serializable")
			if err != nil {
				tx.Rollback()
				return err
			}
			_, err = tx.Exec("select cierre_cursada($1, $2)", trx.ID_materia, trx.ID_comision)
			if err != nil {
				tx.Rollback()
				return err
			}
			err = tx.Commit()
			if err != nil {
				return err
			}
			
		default:
			log.Printf("operación no reconocida: %s\n", trx.Operacion)
		}
	}
	err = rows.Err()
	if err != nil {
		return err
	}
	
	return nil
}

func ejecutarRutaArchivo(rutaArchivo string, db *sql.DB) error {
	contenidoSQL, err := ioutil.ReadFile(rutaArchivo)
	if err != nil {
		return err
	}

	_, err = db.Exec(string(contenidoSQL))
	if err != nil {
		return err
	}
	return nil
}

func crearBaseDeDatos() (*sql.DB, error) {
	db, err := sql.Open("postgres", "user=postgres host=localhost dbname=postgres sslmode=disable")
	if err != nil {
		return nil, err
	}
	defer db.Close()

	_, err = db.Exec(`drop database if exists fuertes_luna_quintana_tonizzo_db1;`)
	if err != nil {
		return nil, err
	}

	_, err = db.Exec(`create database fuertes_luna_quintana_tonizzo_db1;`)
	if err != nil {
		return nil, err
	} else {
		fmt.Printf("Base de datos fuertes_luna_quintana_tonizzo_db1 creada con exito. \n")
	}

	dbNueva, err := sql.Open("postgres", "user=postgres host=localhost dbname=fuertes_luna_quintana_tonizzo_db1 sslmode=disable")
	if err != nil {
		return nil, err
	} else {
		fmt.Printf("Conexion a la base de datos con exito. \n\n")
	}

	return dbNueva, nil
}

func main() {
	crearTablas := "sql/crear_tablas.sql"
	agregarKeys := "sql/agregar_keys.sql"
	eliminarKeys := "sql/eliminar_keys.sql"
	agregarAlumnes := "sql/agregar_alumnes.sql"
	agregarMaterias := "sql/agregar_materias.sql"
	agregarComisiones := "sql/agregar_comisiones.sql"
	agregarCorrelatividades := "sql/agregar_correlatividades.sql"
	agregarPeriodos := "sql/agregar_periodos.sql"
	agregarHA := "sql/agregar_historias_academicas.sql"
	agregarEntradasTRX := "sql/agregar_entradas_trx.sql"

	spApertura := "sql/apertura_inscripcion.sql"
	spInscripcionMateria := "sql/inscripcion_materia.sql"
	spBajaInscripcion := "sql/baja_inscripcion.sql"
	spCierreInscripcion := "sql/cierre_inscripcion.sql"
	spAplicacionDeCupos := "sql/aplicacion_de_cupos.sql"
	spIngresoNotaCursada := "sql/ingreso_nota_cursada.sql"
	spCierreCursada := "sql/cierre_cursada.sql"
	trgEnviarEmail := "sql/envio_emails.sql"
	
	var dbNueva *sql.DB
	var opcion int

	for {
		fmt.Println("Ingrese el valor numerico de la accion a ejecutar:")
		fmt.Println("1. Crea base de datos")
		fmt.Println("2. Crear tablas")
		fmt.Println("3. Agregar keys")
		fmt.Println("4. Eliminar keys")
		fmt.Println("5. Guardar datos en las tablas")
		fmt.Println("6. Guardar stored procedures y triggers")
		fmt.Println("7. Ejecutar tests")
		fmt.Println("8. Salir")
		fmt.Print("Valor: ")

		_, err := fmt.Scanf("%d", &opcion)
		if err != nil {
			fmt.Println("Error al leer la opción:", err)
			continue
		}

		switch opcion {
		case 1:
			dbNueva, err = crearBaseDeDatos()
			if err != nil {
				log.Fatal("Error al crear la base de datos:", err)
			}
		case 2:
			err = ejecutarRutaArchivo(crearTablas, dbNueva)
			if err == nil {
				fmt.Println("Se agregaron las tablas.\n")
			} else {
				fmt.Println("Error al agregar las tablas: ", err)
			}
		case 3:
			err = ejecutarRutaArchivo(agregarKeys, dbNueva)
			if err == nil {
				fmt.Println("Se agregaron las keys.\n")
			} else {
				fmt.Println("Error al agregar las keys: ", err)
			}
		case 4:
			err = ejecutarRutaArchivo(eliminarKeys, dbNueva)
			if err == nil {
				fmt.Println("Se eliminaron las keys.\n")
			} else {
				fmt.Println("Error al eliminar las keys: ", err)
			}
		case 5:
			err = ejecutarRutaArchivo(agregarAlumnes, dbNueva)
			if err == nil {
				fmt.Println("Se guardaron los alumnes.")
			} else {
				fmt.Println("Error al guardar los alumnes: ", err)
			}
			err = ejecutarRutaArchivo(agregarMaterias, dbNueva)
			if err == nil {
				fmt.Println("Se guardaron las materias.")
			} else {
				fmt.Println("Error al guardar las materias: ", err)
			}
			err = ejecutarRutaArchivo(agregarComisiones, dbNueva)
			if err == nil {
				fmt.Println("Se guardaron las comisiones.")
			} else {
				fmt.Println("Error al guardar las comisiones: ", err)
			}
			err = ejecutarRutaArchivo(agregarCorrelatividades, dbNueva)
			if err == nil {
				fmt.Println("Se guardaron las correlatividades.")
			} else {
				fmt.Println("Error al guardar correlatividades: ", err)
			}
			err = ejecutarRutaArchivo(agregarPeriodos, dbNueva)
			if err == nil {
				fmt.Println("Se guardaron los periodos.")
			} else {
				fmt.Println("Error al guardar los periodos: ", err)
			}
			err = ejecutarRutaArchivo(agregarHA, dbNueva)
			if err == nil {
				fmt.Println("Se guardaron las historias academicas.")
			} else {
				fmt.Println("Error al guardar historias academicas: ", err)
			}
			err = ejecutarRutaArchivo(agregarEntradasTRX, dbNueva)
			if err == nil {
				fmt.Println("Se guardaron los valores en entrada_trx.\n")
			} else {
				fmt.Println("Error al guardar entrada_trx: ", err)
			}
		case 6:
			err = ejecutarRutaArchivo(spApertura, dbNueva)
			if err == nil {
				fmt.Println("Se guardó el stored procedure de apertura de inscripción.")
			} else {
				fmt.Println("Error al guardar stored procedure de apertura de inscripción: ", err)
			}
			err = ejecutarRutaArchivo(spInscripcionMateria, dbNueva)
			if err == nil {
				fmt.Println("Se guardó el stored procedure de inscripción a materia.")
			} else {
				fmt.Println("Error al guardar stored procedure de inscripción a materia: ", err)
			}
			err = ejecutarRutaArchivo(spBajaInscripcion, dbNueva)
			if err == nil {
				fmt.Println("Se guardó el stored procedure de baja de inscripción.")
			} else {
				fmt.Println("Error al guardar stored procedure de baja de inscripción: ", err)
			}
			err = ejecutarRutaArchivo(spCierreInscripcion, dbNueva)
			if err == nil {
				fmt.Println("Se guardó el stored procedure de cierre de inscripción.")
			} else {
				fmt.Println("Error al guardar stored procedure de cierre de inscripción: ", err)
			}
			err = ejecutarRutaArchivo(spAplicacionDeCupos, dbNueva)
			if err == nil {
				fmt.Println("Se guardó el stored procedure de aplicación de cupos.")
			} else {
				fmt.Println("Error al guardar stored procedure de aplicación de cupos: ", err)
			}
			err = ejecutarRutaArchivo(spIngresoNotaCursada, dbNueva)
			if err == nil {
				fmt.Println("Se guardó el stored procedure de ingreso de nota de cursada.")
			} else {
				fmt.Println("Error al guardar stored procedure de ingreso de nota de cursada: ", err)
			}
			err = ejecutarRutaArchivo(spCierreCursada, dbNueva)
			if err == nil {
				fmt.Println("Se guardó el stored procedure de cierre de cursada.")
			} else {
				fmt.Println("Error al guardar stored procedure de cierre de cursada: ", err)
			}
			err = ejecutarRutaArchivo(trgEnviarEmail, dbNueva)
			if err == nil {
				fmt.Println("Se guardaron los triggers de envío de emails.\n")
			} else {
				fmt.Println("Error al guardar triggers de envío de emails: ", err)
			}
		case 7:
			err = ejecutarTesteo(dbNueva)
			if err == nil {
				fmt.Println("Se ejecutaron las transacciones de testeo.\n")
			} else {
				fmt.Println("Error al ejecutar las transacciones de testeo: ", err)
			}
		case 8:
			fmt.Println("Saliendo del programa...")
			return
		default:
			fmt.Println("Opción no válida.\n")
		}
	}
}
