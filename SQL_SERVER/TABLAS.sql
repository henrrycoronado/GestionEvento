-- CREATE DATABASE GESTION_EVENTO
-- DROP DATABASE GESTION_EVENTO
-- USE GESTION_EVENTO

-- CREATE SCHEMA evento;
-- CREATE SCHEMA registro;
-- CREATE SCHEMA persona;

--Creacion de tablas

CREATE TABLE persona.usuarios (
    id INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    organizacion VARCHAR(100),
    profesion VARCHAR(50) NOT NULL,
    cargo VARCHAR(50),
	user_password VARCHAR(20) NOT NULL,
	fecha_creacion DATETIME NOT NULL
);

--DROP TABLE persona.usuarios;



CREATE TABLE evento.eventos(
    id INT PRIMARY KEY IDENTITY(1,1),
	id_administrador INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    ubicacion VARCHAR(255) NOT NULL,
    informacion_contacto VARCHAR(250)  NOT NULL,
    fecha_inicio DATETIME NOT NULL,
	fecha_fin DATETIME NOT NULL,
	tipo BINARY NOT NULL,
    estado BINARY NOT NULL,
	max_miembros INT,
	fecha_creacion DATETIME NOT NULL,
	certificados BINARY NOT NULL,
	FOREIGN KEY(id_administrador) 
	REFERENCES persona.usuarios(id)
);

--DROP TABLE evento.eventos;

CREATE TABLE persona.equipos (
    id INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
	miembros_max INT,
    institucion VARCHAR(100) NOT NULL,
    representante_id INT NOT NULL,
	estado BINARY NOT NULL,
	tipo BINARY not null,
	fecha_creacion DATETIME NOT NULL,
    FOREIGN KEY (representante_id) REFERENCES persona.usuarios(id)
);

--DROP TABLE persona.equipos;

CREATE TABLE persona.participantes (
    id INT PRIMARY KEY IDENTITY(1,1),
    id_usuario INT NOT NULL,
    id_equipo INT NOT NULL,
	estado BINARY NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES persona.usuarios(id),
    FOREIGN KEY (id_equipo) REFERENCES persona.equipos(id)
);

--DROP TABLE persona.participantes;


--DROP TABLE registro.inscripciones_equipo;

CREATE TABLE registro.inscripciones_individual (
    id INT PRIMARY KEY IDENTITY(1,1),
    id_evento INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_inscripcion DATETIME NOT NULL,
	estado BINARY NOT NULL,
	certificado BINARY NOT NULL,
	fecha_entrega DATETIME null,
    FOREIGN KEY (id_evento) REFERENCES evento.eventos(id),
    FOREIGN KEY (id_usuario) REFERENCES persona.usuarios(id)
);

--DROP TABLE registro.inscripciones_individual;


--DROP TABLE registro.certificado_equipos

CREATE TABLE registro.inscripciones_equipo (
    id INT PRIMARY KEY IDENTITY(1,1),
    id_evento INT NOT NULL,
	id_equipo INT not null,
    fecha_inscripcion DATETIME NOT NULL,
	estado BINARY NOT NULL,
	certificado BINARY NOT NULL,
	fecha_entrega DATETIME null,
    FOREIGN KEY (id_evento) REFERENCES evento.eventos(id),
	FOREIGN KEY (id_equipo) REFERENCES persona.equipos(id)
);











