use GESTION_EVENTO;
--### 1. `nuevo_usuario`
SELECT * FROM persona.usuarios;
GO
CREATE PROCEDURE obtener_usuario
	@id int
AS
BEGIN
	SELECT * FROM persona.usuarios where id = @id;
END
GO


GO
CREATE PROCEDURE inicio_sesion
	@correo VARCHAR(100),
	@password VARCHAR(20)
AS
BEGIN
	SELECT id FROM persona.usuarios where correo = @correo AND user_password = @password;
END
GO
EXEC inicio_sesion @correo = 'coronadovillcahenrryalberto@gmail.com', @password = '1234';

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
	IF(@correo NOT IN (select correo from persona.usuarios))
	BEGIN
		INSERT INTO persona.usuarios (nombre, direccion, fecha_nacimiento, correo, telefono, organizacion, profesion, cargo, user_password, fecha_creacion)
		VALUES (@nombre, @direccion, @fecha_nacimiento, @correo, @telefono, @organizacion, @profesion, @cargo, @password, GETDATE());
	END
	SELECT id from persona.usuarios where correo = @correo AND user_password = @password;
END;
GO

EXEC nuevo_usuario @nombre = 'Juan', @direccion = 'Los Lotes', @fecha_nacimiento = '2024-06-22', @correo = 'Juan@gmail.com', @telefono = '+591-78425610', @organizacion = 'UCB', @profesion = 'Estudiante', @cargo = 'Ninguno', @password = '1234'

--------- -----------------------------------------------------------------------------


GO
CREATE PROCEDURE PerfilEventosActualParticipando
	@id_usuario INT
AS
BEGIN
	SELECT * FROM evento.eventos e
	WHERE e.estado = 1 AND e.fecha_fin >= GETDATE() AND e.id IN (SELECT id_evento FROM registro.inscripciones_individual i WHERE i.estado = 1 AND i.id_usuario = @id_usuario)
	ORDER BY e.fecha_fin;
END
GO

GO
CREATE PROCEDURE PerfilEventosActualParticipandoEquipo
	@id_usuario INT
AS
BEGIN
	SELECT * FROM evento.eventos e
	WHERE e.estado = 1 AND e.fecha_fin >= GETDATE() 
	AND e.id IN (SELECT i.id_evento FROM registro.inscripciones_equipo i WHERE i.estado = 1 
	AND i.id_equipo in (SELECT p.id_equipo FROM persona.participantes p WHERE p.estado = 1 AND p.id_usuario = @id_usuario))
	ORDER BY e.fecha_fin;

END
GO

GO
CREATE PROCEDURE PerfilEventosHistoricoParticipando
	@id_usuario INT
AS
BEGIN

	SELECT * FROM evento.eventos e
	WHERE e.estado = 1 AND e.id IN (SELECT id_evento FROM registro.inscripciones_individual i WHERE i.estado = 1 AND i.id_usuario = @id_usuario)
	ORDER BY e.fecha_fin;

END
GO

GO
CREATE PROCEDURE PerfilEventosHistoricoParticipandoEquipo
	@id_usuario INT
AS
BEGIN
	SELECT * FROM evento.eventos e
	WHERE e.estado = 1 
	AND e.id IN (SELECT i.id_evento FROM registro.inscripciones_equipo i WHERE i.estado = 1 
	AND i.id_equipo in (SELECT p.id_equipo FROM persona.participantes p WHERE p.estado = 1 AND p.id_usuario = @id_usuario))
	ORDER BY e.fecha_fin;
END
GO

GO
CREATE PROCEDURE PerfilEquiposActualParticipando
	@id_usuario INT
AS
BEGIN
	SELECT * FROM persona.equipos e
	WHERE e.id IN (SELECT p.id_equipo FROM  persona.participantes p WHERE p.id_usuario = @id_usuario AND p.estado = 1)
END
GO

-- -------------------------------------------------------------------------------------------------------


GO
CREATE PROCEDURE EventosVerDisponibles
AS
BEGIN
	SELECT * FROM evento.eventos e
	WHERE e.estado = 1 AND fecha_inicio >= GETDATE()
	ORDER BY fecha_inicio
END
GO

GO
CREATE PROCEDURE EventosVerDetalles
	@id_evento INT
AS
BEGIN
	SELECT * FROM evento.eventos e
	WHERE e.id = @id_evento
END
GO

GO
CREATE PROCEDURE EventoInscribirse
	@id_evento INT,
	@id_participante INT
AS
BEGIN
	DECLARE @mensaje VARCHAR(50);
	IF((SELECT estado FROM evento.eventos WHERE id = @id_evento) = 0)
	BEGIN
		SET @mensaje = 'Evento no disponible, no se pudo inscribir';
	END
	ELSE IF((SELECT fecha_fin FROM evento.eventos WHERE id = @id_evento) < GETDATE())
	BEGIN
		SET @mensaje = 'Evento ya finalizado, no se pudo inscribir';
	END
	ELSE IF((SELECT fecha_inicio FROM evento.eventos WHERE id = @id_evento) < GETDATE())
	BEGIN
		SET @mensaje = 'Evento ya iniciado, no se pudo inscribir';
	END
	ELSE IF(((SELECT tipo FROM evento.eventos WHERE id = @id_evento) = 1 AND @id_participante IN (SELECT i.id_usuario FROM registro.inscripciones_individual i WHERE i.id_evento = @id_evento AND i.estado = 1))
	OR ((SELECT tipo FROM evento.eventos WHERE id = @id_evento) = 0 AND @id_participante IN (SELECT i.id_equipo FROM registro.inscripciones_equipo i WHERE i.id_evento = @id_evento AND i.estado = 1)))
	BEGIN
		SET @mensaje = 'Ya registrado en el evento';
	END
	ELSE
	BEGIN
		IF((SELECT tipo FROM evento.eventos WHERE id = @id_evento) = 1)
		BEGIN
			INSERT INTO registro.inscripciones_individual(id_evento, id_usuario, fecha_inscripcion, estado, certificado, fecha_entrega) VALUES (@id_evento, @id_participante, GETDATE(), 1, 0, null)
		END
		ELSE
		BEGIN
			INSERT INTO registro.inscripciones_equipo(id_evento, id_equipo, fecha_inscripcion, estado, certificado, fecha_entrega) VALUES (@id_evento, @id_participante, GETDATE(), 1, 0, null)
		END
		SET @mensaje = 'Inscrito correctamente';
	END
	SELECT @mensaje AS mensaje
END
GO

GO
CREATE PROCEDURE EventoSalir
	@id_evento INT,
	@id_participante INT
AS
BEGIN
	DECLARE @mensaje VARCHAR(50);
	IF((SELECT estado FROM evento.eventos WHERE id = @id_evento) = 0)
	BEGIN
		SET @mensaje = 'Evento no disponible, Abandono Anulado';
	END
	ELSE IF((SELECT fecha_fin FROM evento.eventos WHERE id = @id_evento) < GETDATE())
	BEGIN
		SET @mensaje = 'Evento ya finalizado, no se abandono.';
	END
	ELSE IF((SELECT tipo FROM evento.eventos WHERE id = @id_evento) = 1)
	BEGIN
		IF(@id_participante IN (SELECT i.id_usuario FROM registro.inscripciones_individual i WHERE i.id_evento = @id_evento AND i.estado = 1))
		BEGIN
			UPDATE registro.inscripciones_individual
			SET estado = 0
			WHERE id_usuario = @id_participante AND id_evento = @id_evento

			SET @mensaje = 'Abandono el evento correctamente.';
		END
		ELSE
		BEGIN
			SET @mensaje = 'No formas parte del evento!!.';
		END
	END
	ELSE
	BEGIN
		IF(@id_participante IN (SELECT i.id_equipo FROM registro.inscripciones_equipo i WHERE i.id_evento = @id_evento AND i.estado = 1))
		BEGIN
			UPDATE registro.inscripciones_equipo
			SET estado = 0
			WHERE id_equipo = @id_participante AND id_evento = @id_evento

			SET @mensaje = 'Abandono el evento correctamente.';
		END
		ELSE
		BEGIN
			SET @mensaje = 'Su equipo no forma parte del evento!!.';
		END
	END
	SELECT @mensaje AS mensaje
END
GO





-- ------------------------------------







GO
CREATE PROCEDURE EquiposVerDispoblesPublico
AS
BEGIN
	SELECT * FROM persona.equipos e
	WHERE e.estado = 1 AND e.tipo = 1 AND (SELECT COUNT(ID) FROM persona.participantes WHERE id_equipo = e.id) < e.miembros_max
	ORDER BY e.fecha_creacion
END
GO

GO
CREATE PROCEDURE EquipoVerDetalle
	@id_equipo INT
AS
BEGIN
	SELECT * FROM evento.eventos e
	WHERE e.id = @id_equipo
END
GO



GO
CREATE PROCEDURE EquipoInscribir
	@id_equipo INT,
	@id_participante INT
AS
BEGIN
	DECLARE @mensaje VARCHAR(50);

	IF((SELECT estado FROM persona.equipos WHERE id = @id_equipo) = 0)
	BEGIN
		SET @mensaje = 'Equipo no disponible, no se pudo inscribir';
	END
	ELSE IF(@id_participante IN (SELECT id_usuario FROM persona.participantes WHERE id_equipo = @id_equipo))
	BEGIN
		SET @mensaje = 'Ya se encuentra registrado en el equipo';
	END
	ELSE IF((SELECT count(id) FROM persona.participantes WHERE id_equipo = @id_equipo) >= (SELECT miembros_max FROM persona.equipos WHERE id = @id_equipo))
	BEGIN
		SET @mensaje = 'Equipo completo, no se pudo inscribir';
	END
	ELSE
	BEGIN
		INSERT INTO persona.participantes(id_usuario, id_equipo, estado)
		VALUES (@id_participante, @id_equipo, 1);
		SET @mensaje = 'Inscrito correctamente';
	END
	SELECT @mensaje AS mensaje
END
GO

GO
CREATE PROCEDURE EquipoSalir
	@id_equipo INT,
	@id_participante INT
AS
BEGIN
	DECLARE @mensaje VARCHAR(50);
	IF((SELECT estado FROM persona.equipos WHERE id = @id_equipo) = 0)
	BEGIN
		SET @mensaje = 'Equipo no disponible, Abandono Anulado';
	END
	ELSE IF((SELECT representante_id FROM persona.equipos WHERE id = @id_equipo) = @id_participante)
	BEGIN
		SET @mensaje = 'Eres el anfitrion, no se abandono.';
	END
	ELSE IF(@id_participante IN (SELECT i.id_usuario FROM persona.participantes i WHERE i.id_equipo = @id_equipo AND i.estado = 1))
	BEGIN
			UPDATE persona.participantes
			SET estado = 0
			WHERE id_usuario = @id_participante AND id_equipo = @id_equipo

			SET @mensaje = 'Abandono el equipo correctamente.';
	END
	SELECT @mensaje AS mensaje
END
GO

-- ---------------------------------------------------------------------

GO
CREATE PROCEDURE GestionEventosObtenertusEventos
	@id_administrador INT
AS
BEGIN
	SELECT * FROM evento.eventos
	WHERE id_administrador = @id_administrador AND estado = 1
END
GO

GO
CREATE PROCEDURE GestionEventosModificarEvento
	@id_evento INT ,
	@nombre VARCHAR(100),
	@descripcion VARCHAR(max),
	@ubicacion VARCHAR(255),
	@informacionContacto VARCHAR(250),
	@fechainicio DATETIME,
	@fechafin DATETIME
AS
BEGIN
	DECLARE @mensaje VARCHAR(50);
	IF(@nombre IN (SELECT nombre FROM evento.eventos WHERE id = @id_evento))
	BEGIN
		SET @mensaje = 'Nombre repetido, ingresa otro.';
	END
	ELSE IF((SELECT fecha_fin FROM evento.eventos WHERE id = @id_evento)<= GETDATE())
	BEGIN
		SET @mensaje = 'Evento Finalizado, no se puede modificar.';
	END
	ELSE IF((SELECT fecha_inicio FROM evento.eventos WHERE id = @id_evento)<= GETDATE())
	BEGIN
		UPDATE evento.eventos
		set nombre = @nombre, descripcion = @descripcion, ubicacion = @ubicacion, informacion_contacto = @informacionContacto, fecha_fin = @fechafin
		WHERE id = @id_evento

		SET @mensaje = 'Evento modificado menos fecha de inicio, el evento ya inicio.';
	END
	ELSE
	BEGIN
		UPDATE evento.eventos
		set nombre = @nombre, descripcion = @descripcion, ubicacion = @ubicacion, informacion_contacto = @informacionContacto,fecha_inicio = @fechainicio, fecha_fin = @fechafin
		WHERE id = @id_evento

		SET @mensaje = 'Evento Modificado.';
	END
	SELECT @mensaje AS mensaje;
END
GO

GO
CREATE PROCEDURE GestionEventosListParticipantestusEventos     
	@id_evento INT
AS
BEGIN
	IF((SELECT tipo FROM evento.eventos WHERE id = @id_evento) = 1)
	BEGIN
		SELECT * FROM persona.usuarios 
		WHERE id IN (SELECT id_usuario FROM registro.inscripciones_individual i WHERE id_evento = @id_evento AND i.estado = 1)
	END
	ELSE
	BEGIN
		SELECT * FROM persona.equipos u
		WHERE u.id IN (SELECT e.id_equipo FROM registro.inscripciones_equipo e where e.id_evento = @id_evento AND e.estado = 1)
	END
END
GO

GO
CREATE PROCEDURE GestionEventoEliminarEvento
	@id_evento INT
AS
BEGIN
	DECLARE @mensaje VARCHAR(50);
	
		UPDATE evento.eventos
		set estado = 0
		WHERE id = @id_evento

		SET @mensaje = 'Evento Eliminado.';
	SELECT @mensaje AS mensaje;
END
GO


-- -------------------------------------------------------------------




GO
CREATE PROCEDURE GestionEquipoListEquipo
	@id_administrador INT
AS
BEGIN
	SELECT * FROM persona.equipos
	WHERE representante_id = @id_administrador AND estado = 1
END
GO

GO
CREATE PROCEDURE GestionEquiposModificarEquipo 
	@id_equipo INT,
	@nombre VARCHAR(100),
	@miembros_max int,
	@institucion VARCHAR(100),
	@tipo BINARY
AS
BEGIN
	DECLARE @mensaje VARCHAR(50);
	IF(@nombre IN (SELECT nombre FROM persona.equipos WHERE id = @id_equipo))
	BEGIN
		SET @mensaje = 'Nombre repetido, ingresa otro.';
	END
	ELSE
	BEGIN
		UPDATE persona.equipos
		set nombre = @nombre, miembros_max = @miembros_max, institucion = @institucion, tipo = @tipo
		WHERE id = @id_equipo

		SET @mensaje = 'Equipo modificado.';
	END
	SELECT @mensaje AS mensaje;
END
GO

GO
CREATE PROCEDURE GestionEquipoListParticipantes     
	@id_equipo INT
AS
BEGIN
	SELECT * FROM persona.usuarios u
	where u.id IN (select p.id_usuario FROM persona.participantes p where p.id_equipo = @id_equipo AND p.estado = 1)
END
GO

GO
CREATE PROCEDURE GestionEquipoEliminarEquipo 
	@id_equipo INT
AS
BEGIN
	DECLARE @mensaje VARCHAR(50);
	
		UPDATE persona.equipos
		set estado = 0
		WHERE id = @id_equipo

		SET @mensaje = 'Equipo Eliminado.';
	SELECT @mensaje AS mensaje;
END
GO



-- ------------------------------------------------


GO
CREATE PROCEDURE CrearEvento
	@id_administrador INT,
	@nombre VARCHAR(100),
	@descripcion VARCHAR(max),
	@ubicacion VARCHAR(255),
	@informacionContacto VARCHAR(250),
	@fechainicio DATETIME,
	@fechafin DATETIME,
	@tipo BINARY
AS
BEGIN
	DECLARE @mensaje VARCHAR(50);
	IF(@nombre IN (SELECT nombre FROM evento.eventos WHERE id_administrador = @id_administrador))
	BEGIN
		SET @mensaje = 'Nombre repetido, ingresa otro.';
	END
	ELSE
	BEGIN
		INSERT INTO evento.eventos (id_administrador, nombre, descripcion, ubicacion, informacion_contacto, fecha_inicio, fecha_fin, tipo, estado, fecha_creacion, certificados)
		VALUES (@id_administrador, @nombre, @descripcion, @ubicacion, @informacionContacto, @fechainicio, @fechafin, @tipo, 1, GETDATE(), 1)
		SET @mensaje = 'Evento Creado.';
	END
	SELECT @mensaje AS mensaje;
END
GO

EXEC CrearEvento @id_administrador = 2,
	@nombre = 'Evento 6',
	@descripcion = 'Creado por el usuario 2',
	@ubicacion = 'La ramada',
	@informacionContacto = 'Ninguno',
	@fechainicio = '2024-07-01 12:00:00',
	@fechafin = '2024-07-14 12:00:00',
	@tipo = 0;

GO
CREATE PROCEDURE CrearEquipo
	@id_administrador INT,
	@nombre VARCHAR(100),
	@miembros_max int,
	@institucion VARCHAR(100),
	@tipo BINARY
AS
BEGIN
	DECLARE @mensaje VARCHAR(50);
	IF(@nombre IN (SELECT nombre FROM persona.equipos WHERE representante_id = @id_administrador))
	BEGIN
		SET @mensaje = 'Nombre repetido, ingresa otro.';
	END
	ELSE
	BEGIN
		INSERT INTO persona.equipos (nombre, miembros_max, institucion, representante_id, tipo, estado, fecha_creacion)
		VALUES (@nombre, @miembros_max, @institucion, @id_administrador, @tipo, 1, GETDATE())
		SET @mensaje = 'Equipo Creado.';
	END
	SELECT @mensaje AS mensaje;
END
GO

EXEC CrearEquipo @id_administrador = 4,
	@nombre = 'Equipo 3',
	@miembros_max = null,
	@institucion = 'UCB',
	@tipo = 0


-- --------------------------------------------------
GO
CREATE PROCEDURE CertificadosEntregar
	@id_evento INT
AS
BEGIN
	DECLARE @mensaje VARCHAR(50);
	DECLARE @id_usuario INT;
	DECLARE @contador INT;
	IF((SELECT certificados FROM evento.eventos WHERE id = @id_evento) = 0)
	BEGIN
		SET @mensaje = 'El evento ya entrego sus certificados.';
	END
	ELSE IF((SELECT tipo FROM evento.eventos WHERE id = @id_evento) = 1)
	BEGIN
		IF((SELECT fecha_fin FROM evento.eventos WHERE id = @id_evento) > GETDATE())
		BEGIN
			SET @mensaje = 'Evento aun no finalizado.';
		END
		ELSE
		BEGIN
			SELECT @contador = count(id) from registro.inscripciones_individual where id_evento = @id_evento AND estado = 1 AND certificado = 0;
			WHILE @contador > 0
			BEGIN
				SET @id_usuario = (SELECT TOP 1 id_usuario FROM registro.inscripciones_individual WHERE id_evento = @id_evento AND estado = 1 AND certificado = 0);

				UPDATE registro.inscripciones_individual
				set certificado = 1, fecha_entrega = GETDATE()
				WHERE id_usuario = @id_usuario AND id_evento = @id_evento

				SET @contador = @contador - 1;
			END
			UPDATE evento.eventos
			set certificados = 0
			WHERE id = @id_evento

			SET @mensaje = 'Certificados entregados';
		END
	END
	ELSE
	BEGIN
		IF((SELECT fecha_fin FROM evento.eventos WHERE id = @id_evento) > GETDATE())
		BEGIN
			SET @mensaje = 'Evento aun no finalizado.';
		END
		ELSE
		BEGIN
			SELECT @contador = count(id) from registro.inscripciones_equipo where id_evento = @id_evento AND estado = 1 AND certificado = 0;
			WHILE @contador > 0
			BEGIN
				SET @id_usuario = (SELECT TOP 1 id_equipo FROM registro.inscripciones_equipo WHERE id_evento = @id_evento AND estado = 1 AND certificado = 0);

				UPDATE registro.inscripciones_equipo
				set certificado = 1, fecha_entrega = GETDATE()
				WHERE id_equipo = @id_usuario AND id_evento = @id_evento

				SET @contador = @contador - 1;
			END

			UPDATE evento.eventos
			set certificados = 0
			WHERE id = @id_evento

			SET @mensaje = 'Certificados entregados';
		END
	END
	SELECT @mensaje AS mensaje;
END
GO

EXEC CertificadosEntregar @id_evento = 1;

GO
CREATE PROCEDURE CertificadosVerIndividual
	@id_usuario INT
AS
BEGIN
	SELECT * FROM registro.inscripciones_individual i
	Where i.estado = 1 AND i.certificado = 1 
	AND i.id_usuario = @id_usuario;
END
GO

GO
CREATE PROCEDURE CertificadosVerEquipos
	@id_usuario INT
AS
BEGIN
	SELECT * FROM registro.inscripciones_equipo e
	Where e.estado = 1 AND e.certificado = 1 
	AND e.id_equipo IN (SELECT p.id_equipo FROM persona.participantes p where p.id_usuario = @id_usuario AND p.estado = 1)
END
GO

EXEC CertificadosVerIndividual @id_usuario = 1;
