package main

import (
	"encoding/json"
	"fmt"
	bolt "go.etcd.io/bbolt"
	"log"
	"strconv"
	"os"
)

type Alumne struct {
	IDAlumne       int    `json:"id_alumne"`
	Nombre         string `json:"nombre"`
	Apellido       string `json:"apellido"`
	DNI            int    `json:"dni"`
	FechaNacimiento string `json:"fecha_nacimiento"`
	Telefono       string `json:"telefono"`
	Email          string `json:"email"`
}

type Materia struct {
	IDMateria int    `json:"id_materia"`
	Nombre    string `json:"nombre"`
}

type Comision struct {
	IDMateria  int `json:"id_materia"`
	IDComision int `json:"id_comision"`
	Cupo       int `json:"cupo"`
}

type Cursada struct {
	IDMateria    int    `json:"id_materia"`
	IDAlumne     int    `json:"id_alumne"`
	IDComision   int    `json:"id_comision"`
	FInscripcion string `json:"f_inscripcion"`
	Nota         int    `json:"nota"`
	Estado       string `json:"estado"`
}

func main() {
	var db *bolt.DB
	var opcion int
	
	for {
		fmt.Println("Ingrese el valor numerico de la accion a ejecutar:")
		fmt.Println("1. Crear base de datos NoSQL")
		fmt.Println("2. Agregar buckets")
		fmt.Println("3. Guardar alumnos")
		fmt.Println("4. Guardar materias")
		fmt.Println("5. Guardar comisiones")
		fmt.Println("6. Guardar inscripciones")
		fmt.Println("7. Salir del programa")
		fmt.Print("Valor: ")
		
		_, err := fmt.Scanf("%d", &opcion)
		if err != nil {
			fmt.Println("Error al leer la opción:", err)
			continue
		}

		switch opcion {
		case 1:
			err = borrarBaseDeDatosSiExiste()
			if err == nil {
				fmt.Println("Se borro la base de datos si existia.")
			} else {
				fmt.Println("Ocurrio un error al eliminar la base de datos si existia.")
			}
			db, err = crearBaseDeDatosNoSQL()
			if err != nil {
				log.Fatal("Error al crear la base de datos:", err)
			} else {
				fmt.Println("Se creó la base de datos.\n")
				defer db.Close()
			}
		case 2:
			if db == nil {
				fmt.Println("Primero se debe crear la base de datos.\n")
				continue
			}
			crearBuckets(db)
			fmt.Println("Se crearon los buckets.\n")
		case 3:
			if db == nil {
				fmt.Println("Primero se debe crear la base de datos.\n")
				continue
			}
			guardarAlumnes(db)
			fmt.Println("Se guardaron los alumnos.\n")
		case 4:
			if db == nil {
				fmt.Println("Primero se debe crear la base de datos.\n")
				continue
			}
			guardarMaterias(db)
			fmt.Println("Se guardaron las materias.\n")
		case 5:
			if db == nil {
				fmt.Println("Primero se debe crear la base de datos.\n")
				continue
			}
			guardarComisiones(db)
			fmt.Println("Se guardaron las comisiones.\n")
		case 6:
			if db == nil {
				fmt.Println("Primero se debe crear la base de datos.\n")
				continue
			}
			guardarCursadas(db)
			fmt.Println("Se guardaron las inscripciones a cursada.\n")
		case 7:
			fmt.Println("Saliendo del programa...\n")
			return
		default:
			fmt.Println("Opción no válida.\n")
		}
	}
}

func borrarBaseDeDatosSiExiste() error {
	_, err := os.Stat("fuertes-luna-quintana-tonizzo-db1.db")
		if err == nil {
			err = os.Remove("fuertes-luna-quintana-tonizzo-db1.db")
			if err != nil {
				return err
			}
		} 
	return nil
}

func crearBaseDeDatosNoSQL() (*bolt.DB, error) {
	db, err := bolt.Open("fuertes-luna-quintana-tonizzo-db1.db", 0600, nil)
	if err != nil {
		return nil, err
	}

	return db, nil
}

func crearBuckets(db *bolt.DB) error {
	return db.Update(func(tx *bolt.Tx) error {
		_, err := tx.CreateBucketIfNotExists([]byte("alumne"))
		if err != nil {
			return err
		}
		_, err = tx.CreateBucketIfNotExists([]byte("materia"))
		if err != nil {
			return err
		}
		_, err = tx.CreateBucketIfNotExists([]byte("comision"))
		if err != nil {
			return err
		}
		_, err = tx.CreateBucketIfNotExists([]byte("cursada"))
		if err != nil {
			return err
		}
		return nil
	})
}

func guardarAlumnes(db *bolt.DB) {
	alumnes := []Alumne{
		{1, "Ken", "Thompson", 5153057, "1995-05-05", "15-2889-7948", "ken@thompson.org"},
		{2, "Dennis", "Ritchie", 25610126, "1955-04-11", "15-7811-5045", "dennis@ritchie.org"},
		{3, "Donald", "Knuth", 9168297, "1984-04-05", "15-2780-6005", "don@knuth.org"},
		{4, "Rob", "Pike", 4915593, "1946-08-16", "15-1114-9719", "rob@pike.org"},
		{5, "Douglas", "McIlroy", 33187055, "1939-06-09", "15-9625-0245", "douglas@mcilroy.org"},
		{6, "Brian", "Kernighan", 13897948, "1992-11-22", "15-6410-6066", "brian@kernighan.org"},
	}

	// Guardar Alumnes
	for _, alumne := range alumnes {
		data, err := json.MarshalIndent(alumne, "", "    ")
		if err != nil {
			log.Fatal(err)
		}

		err = CreateUpdate(db, "alumne", []byte(strconv.Itoa(alumne.IDAlumne)), data)
		if err != nil {
			log.Fatal(err)
		}

		resultado, err := ReadUnique(db, "alumne", []byte(strconv.Itoa(alumne.IDAlumne)))
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("Alumno: %s\n", resultado)
	}
}

func guardarMaterias(db *bolt.DB) {
	materias := []Materia{
		{1, "Taller Inicial Común: Taller de Lectura y Escritura"},
		{2, "Taller Inicial Orientado: Ciencias Exactas"},
	}

	// Guardar Materias
	for _, materia := range materias {
		data, err := json.MarshalIndent(materia, "", "    ")
		if err != nil {
			log.Fatal(err)
		}

		err = CreateUpdate(db, "materia", []byte(strconv.Itoa(materia.IDMateria)), data)
		if err != nil {
			log.Fatal(err)
		}

		resultado, err := ReadUnique(db, "materia", []byte(strconv.Itoa(materia.IDMateria)))
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("Materia: %s\n", resultado)
	}
}

func guardarComisiones(db *bolt.DB) {
	comisiones := []Comision{
		{1, 1, 5},
		{2, 1, 5},
	}

	// Guardar Comisiones
	for _, comision := range comisiones {
		data, err := json.MarshalIndent(comision, "", "    ")
		if err != nil {
			log.Fatal(err)
		}

		key := fmt.Sprintf("%d_%d", comision.IDMateria, comision.IDComision)
		err = CreateUpdate(db, "comision", []byte(key), data)
		if err != nil {
			log.Fatal(err)
		}

		resultado, err := ReadUnique(db, "comision", []byte(key))
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("Comision: %s\n", resultado)
	}
}

func guardarCursadas(db *bolt.DB) {
	cursadas := []Cursada{
		{1, 1, 1, "2024-06-07", 0, "en espera"},
		{1, 2, 1, "2024-06-07", 0, "en espera"},
		{1, 3, 1, "2024-06-07", 0, "en espera"},
		{2, 4, 1, "2024-06-07", 0, "en espera"},
		{2, 5, 1, "2024-06-07", 0, "en espera"},
		{2, 6, 1, "2024-06-07", 0, "en espera"},
	}

	// Guardar Cursadas
	for _, cursada := range cursadas {
		data, err := json.MarshalIndent(cursada, "", "    ")
		if err != nil {
			log.Fatal(err)
		}

		key := fmt.Sprintf("%d_%d", cursada.IDAlumne, cursada.IDMateria)
		err = CreateUpdate(db, "cursada", []byte(key), data)
		if err != nil {
			log.Fatal(err)
		}

		resultado, err := ReadUnique(db, "cursada", []byte(key))
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("Cursada: %s\n", resultado)
	}
}

func CreateUpdate(db *bolt.DB, bucketName string, key []byte, val []byte) error {
	// abre transacción de escritura
	tx, err := db.Begin(true)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	b, _ := tx.CreateBucketIfNotExists([]byte(bucketName))

    err = b.Put(key, val)
    if err != nil {
        return err
    }

	// cierra transacción
	if err := tx.Commit(); err != nil {
		return err
	}

	return nil
}

func ReadUnique(db *bolt.DB, bucketName string, key []byte) ([]byte, error) {
	var buf []byte

    // abre una transacción de lectura
    err := db.View(func(tx *bolt.Tx) error {
        b := tx.Bucket([]byte(bucketName))
        buf = b.Get(key)
        return nil
    })

    return buf, err
}
