-- use GESTION_EVENTO
--1. Crear Cuenta de Usuario

GO
CREATE PROCEDURE nuevo_usuario
    @nombre VARCHAR(100), 
    @direccion VARCHAR(255),
    @fecha_nacimiento DATE,
    @correo VARCHAR(100),
    @telefono VARCHAR(20),
    @organizacion VARCHAR(100),
    @profesion VARCHAR(50),
	@cargo VARCHAR(50),
	@password VARCHAR(20)
	AS
	BEGIN
		INSERT INTO persona.usuarios (nombre, direccion, fecha_nacimiento, correo, telefono, organizacion, profesion, cargo, user_password)
		VALUES (@nombre, @direccion, @fecha_nacimiento, @correo, @telefono, @organizacion, @profesion, @cargo, @password)
	END;
GO

--2. Iniciar Sesión

GO
CREATE PROCEDURE inicio_sesion
    @correo VARCHAR(100),
	@password VARCHAR(20)
	AS
	BEGIN
		SELECT *
		FROM persona.usuarios 
		WHERE correo = @correo AND user_password = @password;
	END;
GO

GO
CREATE PROCEDURE cambiar_datos
	@id INT,
    @correo VARCHAR(100),
	@nombre VARCHAR(100),
	@direccion VARCHAR(250),
	@telefono VARCHAR(20),
	@organizacion VARCHAR(100),
	@profesion VARCHAR(50),
	@cargo VARCHAR(50)
	AS
	BEGIN
		UPDATE persona.usuarios
		SET nombre = @nombre, direccion = @direccion, telefono = @telefono, organizacion = @organizacion, profesion = @profesion, cargo = @cargo
		WHERE id = @id AND correo = @correo
	END;
GO
GO
CREATE PROCEDURE cambiar_credenciales
	@id INT,
    @correo VARCHAR(100),
	@password VARCHAR(20)
	AS
	BEGIN
		UPDATE persona.usuarios
		SET correo = @correo, user_password = @password
		WHERE id = @id
	END;
GO




--4. Visualizar Eventos Disponibles



GO
CREATE PROCEDURE eventos_disponibles
	AS
	BEGIN
		SELECT id, nombre, descripcion, ubicacion, informacion_contacto,
		fecha_inicio, fecha_fin, tipo, max_miembros, max_miembros_equipos, fecha_creacion 
		FROM evento.eventos 
		WHERE fecha_inicio >= GETDATE() AND estado != 0;
	END;
GO
GO
CREATE PROCEDURE eventos_totales
	AS
	BEGIN
		SELECT id, nombre, descripcion, ubicacion, informacion_contacto,
		fecha_inicio, fecha_fin, tipo, max_miembros, fecha_creacion 
		FROM evento.eventos 
		WHERE estado != 0;
	END;
GO


--5. Inscripción a un Evento


GO
CREATE PROCEDURE inscripcion_individual
	@id_usuario INT,
	@id_evento INT
	AS
	BEGIN
		INSERT INTO registro.inscripciones_individual (id_evento, id_usuario, fecha_inscripcion, estado)
		VALUES(@id_evento, @id_usuario, GETDATE(), 1);
	END;
GO


GO
CREATE PROCEDURE inscripcion_grupal
	@id_equipo INT,
	@id_evento INT
	AS
	BEGIN
		INSERT INTO registro.inscripciones_equipo (id_evento, id_equipo, fecha_inscripcion, estado)
		VALUES(@id_evento, @id_equipo, GETDATE(), 1);
	END;
GO


--6. Obtener Comprobante de Registro por Email
---Esto implica una combinación de SQL y lógica de servidor. El SQL para obtener los detalles podría ser:



GO
CREATE PROCEDURE ver_comprobante
	@num_registro INT,
	@tipo BINARY
	AS
	BEGIN
		IF(@tipo = 1)
		BEGIN
			SELECT i.id, i.fecha_inscripcion, e.nombre, e.descripcion, e.ubicacion, e.fecha_inicio, e.fecha_fin,
			u.nombre AS usuario_nombre, u.correo, i.estado
			FROM registro.inscripciones_individual i
			JOIN evento.eventos e ON i.id_evento = e.id
			JOIN persona.usuarios u ON i.id_usuario = u.id
			WHERE i.id = @num_registro;
		END
		ELSE
		BEGIN
			SELECT i.id, i.fecha_inscripcion, e.nombre, e.descripcion, e.ubicacion, e.fecha_inicio, e.fecha_fin,
			u.nombre AS nombre_equipo, i.estado
			FROM registro.inscripciones_equipo i
			JOIN evento.eventos e ON i.id_evento = e.id
			JOIN persona.equipos u ON i.id_equipo = u.id
			WHERE i.id = @num_registro;
		END
	END;
GO


--El servidor luego enviaría el correo electrónico con estos detalles.

------Administrar Eventos

--7. Crear Evento


GO
CREATE PROCEDURE crear_evento
	@id_usuario INT,
	@nombre VARCHAR(100),
	@descripcion TEXT,
	@ubicacion VARCHAR(255),
	@informacion_contacto VARCHAR(250),
    @fecha_inicio DATETIME,
	@fecha_fin DATETIME,
	@max_miembros INT,
	@max_miembros_equipo INT,
	@tipo BINARY
    
	AS
	BEGIN
		IF(@tipo = 1)
		BEGIN
			INSERT INTO evento.eventos (id_administrador, nombre, descripcion, ubicacion, informacion_contacto,
			fecha_inicio,fecha_fin, tipo, max_miembros, max_miembros_equipos, estado, fecha_creacion)
			VALUES (@id_usuario, @nombre, @descripcion, @ubicacion, @informacion_contacto, @fecha_inicio, @fecha_fin, 1, @max_miembros, null, 1, GETDATE());
		END
		ELSE
		BEGIN
			INSERT INTO evento.eventos (id_administrador, nombre, descripcion, ubicacion, informacion_contacto,
			fecha_inicio,fecha_fin, tipo, max_miembros, max_miembros_equipos, estado, fecha_creacion)
			VALUES (@id_usuario, @nombre, @descripcion, @ubicacion, @informacion_contacto, @fecha_inicio, @fecha_fin, 0, @max_miembros, @max_miembros_equipo, 1, GETDATE());
		END
	END;
GO

-----Reportes

--8. Historial de Eventos Realizados y Participaciones del Usuario


GO
CREATE PROCEDURE historial_eventos_realizados
	@id_administrador INT
	AS
	BEGIN
		SELECT e.id, e.nombre, e.descripcion, e.fecha_inicio, e.fecha_fin, e.tipo 
		FROM evento.eventos e
		where id_administrador = @id_administrador AND estado = 1
		ORDER BY fecha_creacion
	END;
GO
GO
CREATE PROCEDURE historial_participaciones
	@id_usuario INT,
	@tipo BINARY 
	AS
	BEGIN
		IF(@tipo = 1)
		BEGIN
			SELECT e.id, e.nombre, e.descripcion, e.fecha_inicio, e.fecha_fin, e.tipo, ii.fecha_inscripcion
			FROM evento.eventos e
			INNER JOIN registro.inscripciones_individual ii
			ON ii.id_evento = e.id
			where ii.id_usuario = @id_usuario AND ii.estado = 1
			ORDER BY ii.fecha_inscripcion
		END
		ELSE
		BEGIN
			SELECT e.id, e.nombre, e.descripcion, e.fecha_inicio, e.fecha_fin, e.tipo, ie.fecha_inscripcion
			FROM evento.eventos e
			INNER JOIN registro.inscripciones_equipo ie
			ON ie.id_evento = e.id
			INNER JOIN persona.participantes p
			ON p.id_equipo = ie.id_equipo
			where p.id_usuario = @id_usuario AND p.estado = 1 AND ie.estado = 1
			ORDER BY ie.fecha_inscripcion
		END
		
	END;
GO



--9. Certificados de Participación Individual

GO
CREATE PROCEDURE historial_credenciales_usuario
	@id_usuario INT,
	@tipo BINARY
	AS
	BEGIN
		IF(@tipo = 1)
		BEGIN
			SELECT e.id, e.nombre, e.descripcion, e.fecha_inicio, e.fecha_fin, e.tipo, ii.id_usuario, ci.archivo, ci.fecha_emision 
			FROM evento.eventos e
			INNER JOIN registro.inscripciones_individual ii
			ON ii.id_evento = e.id
			INNER JOIN registro.certificado_individual ci
			ON ci.id_inscripcion_individual = ii.id
			where ii.id_usuario = @id_usuario AND ii.estado = 1
			ORDER BY ci.fecha_emision
		END
		ELSE
		BEGIN
			SELECT e.id, e.nombre, e.descripcion, e.fecha_inicio, e.fecha_fin, e.tipo, ie.id_equipo, ce.archivo, ce.fecha_emision 
			FROM evento.eventos e
			INNER JOIN registro.inscripciones_equipo ie
			ON ie.id_evento = e.id
			INNER JOIN registro.certificado_equipos ce
			ON ce.id_inscripcion_equipo = ie.id
			where ce.id_usuario = @id_usuario AND ie.estado = 1
			ORDER BY ce.fecha_emision
		END
	END;
GO

--10. Lista de Registrados en un Evento--

GO
CREATE PROCEDURE lista_inscipcion_evento
	@id_evento INT
	AS
	BEGIN
		IF((SELECT e.tipo FROM evento.eventos e WHERE e.id = @id_evento) = 1)
		BEGIN
			SELECT i.id, u.nombre, u.correo, u.telefono 
			FROM registro.inscripciones_individual i
			INNER JOIN persona.usuarios u 
			ON i.id_usuario = u.id
			WHERE i.id_evento = @id_evento AND i.estado = 1;
		END
		ELSE
		BEGIN
			SELECT ie.id, u.nombre, u.correo, u.telefono, e.id, e.nombre 
			FROM registro.inscripciones_equipo ie
			INNER JOIN persona.equipos e ON ie.id_equipo = e.id
			INNER JOIN persona.participantes p ON e.id = p.id_equipo
			INNER JOIN persona.usuarios u on p.id_usuario = u.id
			WHERE ie.id_evento = @id_evento AND ie.estado = 1 AND e.estado = 1 AND p.estado = 1;
		END
	END;
GO