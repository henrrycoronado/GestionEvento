--TRIGGERS
USE GESTION_EVENTO;


--ELIMINAR USUARIO
GO
CREATE TRIGGER ELIMINAR_USUARIO
ON persona.usuarios
INSTEAD OF DELETE
AS
BEGIN
   RAISERROR('No se puede borrar un cliente. Funcion NO HABILITADA', 16, 1)
   ROLLBACK TRANSACTION;
END;
GO
-- MODIFICAR USUARIO

GO
CREATE TRIGGER MODIFICAR_USUARIO
ON persona.usuarios
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @id INT; SELECT @id = id FROM deleted;
	DECLARE @user_password VARCHAR(20); SELECT @user_password = user_password FROM inserted;
    DECLARE @correo VARCHAR(100); SELECT @correo = correo FROM inserted;
	DECLARE @user_passwordANT VARCHAR(20); SELECT @user_password = user_password FROM deleted;
    DECLARE @correoANT VARCHAR(100); SELECT @correo = correo FROM deleted;
	IF((select count(id) from registro.usuarios_historial where id = @id AND razon = 'MODIFICAR PERFIL' AND MONTH(fecha) = MONTH(GETDATE()) ) < 5
	AND @correo = @correoANT AND @user_password = @user_passwordANT)
	BEGIN
		DECLARE @nombre VARCHAR(100); SELECT @nombre = nombre FROM inserted;
		DECLARE @direccion VARCHAR(255); SELECT @direccion = direccion FROM inserted;
		DECLARE @telefono VARCHAR(20); SELECT @telefono = telefono FROM inserted;
		DECLARE @organizacion VARCHAR(100); SELECT @organizacion = organizacion FROM inserted;
		DECLARE @profesion VARCHAR(50); SELECT @profesion = profesion FROM inserted;
		DECLARE @cargo VARCHAR(50); SELECT @cargo = cargo FROM inserted;
		UPDATE persona.usuarios
		SET nombre = @nombre, direccion = @direccion, telefono = @telefono, organizacion = @organizacion, profesion = @profesion, cargo = @cargo
		WHERE id = @id
		INSERT INTO registro.usuarios_historial(id_usuario, razon, fecha) VALUES (@id, 'MODIFICAR PERFIL', GETDATE())
	END
	ELSE IF((select count(id) from registro.usuarios_historial where id = @id AND razon = 'MODIFICAR CREDENCIALES' AND MONTH(fecha) = MONTH(GETDATE()) ) < 2
	AND (@correo != @correoANT OR @user_password != @user_passwordANT))
	BEGIN
		UPDATE persona.usuarios
		SET correo = @correo, user_password = @user_password
		WHERE id = @id
		INSERT INTO registro.usuarios_historial(id_usuario, razon, fecha) VALUES (@id, 'MODIFICAR CREDENCIALES', GETDATE())
	END
	ELSE
	BEGIN
		RAISERROR('Perfil no modificado.', 16, 2)
		ROLLBACK TRANSACTION;
	END
END;
GO

--CREAR EVENTO

GO
CREATE TRIGGER CREAR_EVENTO
ON evento.eventos
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @id_administrador INT; SELECT @id_administrador = id_administrador FROM inserted;
    DECLARE @nombre VARCHAR(100); SELECT @nombre = nombre FROM inserted;
    DECLARE @fecha_inicio DATETIME; SELECT @fecha_inicio = fecha_inicio FROM inserted;
    DECLARE @fecha_fin DATETIME; SELECT @fecha_fin = fecha_fin FROM inserted;
	DECLARE @tipo BINARY; SELECT @tipo = tipo FROM inserted;
	DECLARE @descripcion VARCHAR(MAX); SELECT @descripcion = descripcion FROM inserted;
	DECLARE @ubicacion VARCHAR(255); SELECT @ubicacion = ubicacion FROM inserted;
	DECLARE @informacion_contacto VARCHAR(250); SELECT @informacion_contacto = informacion_contacto FROM inserted;
	DECLARE @max_miembros INT; SELECT @max_miembros = max_miembros FROM inserted;

	IF(@nombre IN (SELECT nombre FROM evento.eventos WHERE id_administrador = @id_administrador))
	BEGIN
		RAISERROR('Evento no creado, nombre repetido.', 16, 3)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((@fecha_fin <= @fecha_inicio) OR (@fecha_inicio < GETDATE()))
	BEGIN
		RAISERROR('Evento no creado, fechas no validas.', 16, 4)
		ROLLBACK TRANSACTION;
	END
	ELSE IF(@tipo = 1)
	BEGIN
		INSERT INTO evento.eventos(id_administrador, nombre, descripcion, ubicacion, informacion_contacto,
		fecha_inicio, fecha_fin, tipo, max_miembros, max_miembros_equipos, estado, fecha_creacion)
		VALUES(@id_administrador, @nombre, @descripcion, @ubicacion, @informacion_contacto, @fecha_inicio, @fecha_fin,
		@tipo, @max_miembros, null, 1, GETDATE())
	END
	ELSE
	BEGIN
		DECLARE @max_miembros_equipo INT; SELECT @max_miembros_equipo = max_miembros_equipos FROM inserted;
		INSERT INTO evento.eventos(id_administrador, nombre, descripcion, ubicacion, informacion_contacto,
		fecha_inicio, fecha_fin, tipo, max_miembros, max_miembros_equipos, estado, fecha_creacion)
		VALUES(@id_administrador, @nombre, @descripcion, @ubicacion, @informacion_contacto, @fecha_inicio, @fecha_fin,
		@tipo, @max_miembros, @max_miembros_equipo, 1, GETDATE())
	END
END;
GO

--MODIFICAR EVENTO

GO
CREATE TRIGGER MODIFICAR_EVENTO
ON evento.eventos
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @id INT; SELECT @id = id FROM deleted;
	DECLARE @fecha_inicio_antigua DATETIME; SELECT @fecha_inicio_antigua = fecha_inicio FROM deleted
	DECLARE @fecha_fin_antigua DATETIME; SELECT @fecha_fin_antigua = fecha_fin FROM deleted;
	IF(@fecha_inicio_antigua <= GETDATE() OR @fecha_fin_antigua <= GETDATE())
	BEGIN
		RAISERROR('Evento ya iniciado/finalizado, no se puede modificar', 16, 1)
		ROLLBACK TRANSACTION;
	END
	DECLARE @id_administrador INT; SELECT @id_administrador = id_administrador FROM deleted;
    DECLARE @nombre VARCHAR(100); SELECT @nombre = nombre FROM inserted;
	IF(@nombre IN (SELECT NOMBRE FROM evento.eventos WHERE id_administrador = @id_administrador AND estado = 1))
	BEGIN
		RAISERROR('Nombre ya existente, no se puede modificar', 16, 1)
		ROLLBACK TRANSACTION;
	END
	DECLARE @descripcion VARCHAR(MAX); SELECT @descripcion = descripcion FROM inserted;
	DECLARE @ubicacion VARCHAR(255); SELECT @ubicacion = ubicacion FROM inserted;
	DECLARE @informacion_contacto VARCHAR(250); SELECT @informacion_contacto = informacion_contacto FROM inserted;
	DECLARE @fecha_fin DATETIME; SELECT @fecha_fin = fecha_fin FROM inserted;
	DECLARE @fecha_inicio DATETIME; SELECT @fecha_inicio = fecha_inicio FROM inserted;
	IF(@fecha_inicio_antigua <= GETDATE() AND @fecha_fin_antigua > GETDATE())
	BEGIN
		UPDATE evento.eventos
		SET descripcion = @descripcion, ubicacion = @ubicacion, informacion_contacto = @informacion_contacto, fecha_fin = @fecha_fin
		WHERE id = @id
	END
	ELSE
	BEGIN
		UPDATE evento.eventos
		SET nombre = @nombre, descripcion = @descripcion, ubicacion = @ubicacion, informacion_contacto = @informacion_contacto,
		fecha_inicio = @fecha_inicio, fecha_fin = @fecha_fin
		WHERE id = @id
	END
END;
GO

--BORRAR_EVENTO

GO
CREATE TRIGGER BORRAR_EVENTO
ON evento.eventos
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @id_evento INT; SELECT @id_evento = id FROM deleted
	DECLARE @id_administrador INT; SELECT @id_administrador = id_administrador FROM deleted;
    DECLARE @fecha_inicio DATETIME; SELECT @fecha_inicio = fecha_inicio FROM deleted;
    DECLARE @fecha_fin DATETIME; SELECT @fecha_fin = fecha_fin FROM deleted;
	DECLARE @tipo BINARY; SELECT @tipo = tipo FROM deleted;
	IF(@fecha_inicio <= GETDATE() OR @fecha_fin <= GETDATE())
	BEGIN
		RAISERROR('Evento ya finalizado o iniciado', 16, 1)
		ROLLBACK TRANSACTION
	END
	DECLARE @cantidad_inscritos INT;
	DECLARE @id_registro_ind INT ;
	IF(@tipo = 1)
	BEGIN
		SELECT @cantidad_inscritos = COUNT(id) FROM registro.inscripciones_individual WHERE id_evento = @id_evento AND estado = 1; 
		WHILE(@cantidad_inscritos > 0)
		BEGIN
			SELECT @id_registro_ind = (SELECT TOP 1 id FROM registro.inscripciones_individual WHERE id_evento = @id_evento AND estado = 1);
			UPDATE registro.inscripciones_individual
			SET estado = 0
			WHERE id = @id_registro_ind
			SELECT @cantidad_inscritos = @cantidad_inscritos - 1
		END
		UPDATE evento.eventos
		SET estado = 0
		WHERE id = @id_evento
	END
	ELSE
	BEGIN
		SELECT @cantidad_inscritos = COUNT(id) FROM registro.inscripciones_equipo WHERE id_evento = @id_evento AND estado = 1;
		WHILE(@cantidad_inscritos > 0)
		BEGIN
			SELECT @id_registro_ind = (SELECT TOP 1 id FROM registro.inscripciones_equipo WHERE id_evento = @id_evento AND estado = 1);
			UPDATE registro.inscripciones_equipo
			SET estado = 0
			WHERE id = @id_registro_ind
			SELECT @cantidad_inscritos = @cantidad_inscritos - 1
		END
		UPDATE evento.eventos
		SET estado = 0
		WHERE id = @id_evento
	END
END;
GO

--ELIMINAR EQUIPO


GO
CREATE TRIGGER ELIMINAR_EQUIPO
ON persona.equipos
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @id_equipo INT; SELECT @id_equipo = id FROM deleted
	DECLARE @cantidad_inscritos INT;
	DECLARE @id_registro_ind INT ;
	SELECT @cantidad_inscritos = COUNT(id) FROM persona.participantes WHERE id_equipo = @id_equipo AND estado = 1;
		WHILE(@cantidad_inscritos > 0)
		BEGIN
			SELECT @id_registro_ind = (SELECT TOP 1 id FROM persona.participantes WHERE id_equipo = @id_equipo AND estado = 1);
			UPDATE persona.participantes
			SET estado = 0
			WHERE id = @id_registro_ind
			SELECT @cantidad_inscritos = @cantidad_inscritos - 1
		END
		UPDATE persona.equipos
		SET estado = 0
		WHERE id = @id_equipo
END;
GO
GO
CREATE TRIGGER CREAR_EQUIPO
ON persona.equipos
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @nombre VARCHAR(100); SELECT @nombre = nombre FROM inserted
	DECLARE @representante INT; SELECT @representante = representante_id FROM inserted
	IF(@nombre IN (SELECT nombre FROM persona.equipos WHERE representante_id = @representante))
	BEGIN
		RAISERROR('No se creo el equipo, nombre ya existente', 16, 6)
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		DECLARE @miembros_max INT; SELECT @miembros_max = miembros_max FROM inserted
		DECLARE @institucion VARCHAR(100); SELECT @institucion = institucion FROM inserted
		INSERT INTO persona.equipos (nombre, miembros_max, institucion, representante_id, estado, fecha_creacion)
		VALUES (@nombre, @miembros_max, @institucion, @representante, 1, GETDATE())
	END
END;
GO
GO
CREATE TRIGGER MODIFICAR_EQUIPO
ON persona.equipos
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @nombre VARCHAR(100); SELECT @nombre = nombre FROM inserted
	DECLARE @representante INT; SELECT @representante = representante_id FROM deleted
	IF(@nombre IN (SELECT nombre FROM persona.equipos WHERE representante_id = @representante))
	BEGIN
		RAISERROR('No se modifico el equipo, nombre ya existente', 16, 6)
		ROLLBACK TRANSACTION
	END
	ELSE
	BEGIN
		DECLARE @id_equipo INT; SELECT @id_equipo = id FROM inserted
		DECLARE @miembros_max INT; SELECT @miembros_max = miembros_max FROM inserted
		DECLARE @institucion VARCHAR(100); SELECT @institucion = institucion FROM inserted
		UPDATE persona.equipos
		SET nombre = @nombre, miembros_max = @miembros_max, institucion = @institucion
		WHERE id = @id_equipo
	END
END;
GO

--INSERTAR INSCRIPCION DE PARTICIPANTE EQUIPO

GO
CREATE TRIGGER INSERTAR_PARTICIPANTE
ON persona.participantes
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @id_equipo INT; SELECT @id_equipo = id_equipo FROM inserted
	IF((SELECT COUNT(ID) FROM persona.participantes WHERE id_equipo = @id_equipo AND estado = 1)>= (select miembros_max from persona.equipos where id = @id_equipo)
	AND (select miembros_max from persona.equipos where id = @id_equipo) != null)
	BEGIN
		RAISERROR('Equipo Completo, no se pudo ingresar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT estado FROM persona.equipos WHERE id = @id_equipo) = 0)
	BEGIN
		RAISERROR('Equipo no existe, no se pudo ingresar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE
	BEGIN
	   DECLARE @id_usuario INT; SELECT @id_usuario = id_usuario from inserted
	   INSERT INTO persona.participantes(id_usuario, id_equipo, estado)
	   VALUES(@id_usuario, @id_equipo, 1)
	END
END;
GO

GO
CREATE TRIGGER MODIFICAR_PARTICIANTES
ON persona.participantes
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @id INT; SELECT @id = id FROM deleted
	DECLARE @estado BINARY; SELECT @estado = estado FROM inserted
	UPDATE persona.participantes
	SET estado = @estado
	WHERE id = @id
END;
GO
GO
CREATE TRIGGER ELIMINAR_PARTICIPANTE
ON persona.participantes
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @id INT; SELECT @id = id FROM deleted
	UPDATE persona.participantes
	SET estado = 0
	WHERE id = @id
END;
GO


--INSERTAR INSCRIPCION DE PARTICIPANTE_EVENTO (IND)

GO
CREATE TRIGGER ENTRAR_EVENTO_IND
ON registro.inscripciones_individual
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @id_evento INT; SELECT @id_evento = id_evento FROM inserted
	IF((SELECT COUNT(ID) FROM registro.inscripciones_individual WHERE id_evento = @id_evento AND estado = 1)>= (select max_miembros from evento.eventos where id = @id_evento)
	AND (select max_miembros from evento.eventos where id = @id_evento) != null)
	BEGIN
		RAISERROR('Evento Completo, no se pudo ingresar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT estado FROM evento.eventos WHERE id = @id_evento) = 0)
	BEGIN
		RAISERROR('Evento no existe, no se pudo ingresar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT fecha_fin FROM evento.eventos WHERE id = @id_evento) < GETDATE())
	BEGIN
		RAISERROR('Evento ya finalizado, no se puede ingresar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT fecha_inicio FROM evento.eventos WHERE id = @id_evento) < GETDATE())
	BEGIN
		RAISERROR('Evento ya iniciado, no se puede ingresar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE
	BEGIN
	   DECLARE @id_usuario INT; SELECT @id_usuario = id_usuario from inserted
	   INSERT INTO registro.inscripciones_individual(id_usuario, id_evento, estado, fecha_inscripcion)
	   VALUES(@id_usuario, @id_evento, 1, GETDATE())
	END
END;
GO
GO
CREATE TRIGGER MODIFICAR_PARTICIANTES_EVENTO_IND
ON registro.inscripciones_individual
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @id INT; SELECT @id = id FROM deleted
	DECLARE @id_evento INT; SELECT @id_evento = id_evento FROM deleted
	IF((SELECT fecha_inicio FROM evento.eventos WHERE id = @id_evento) <= GETDATE())
	BEGIN
		RAISERROR('Evento ya finalizado/iniciado, no se puede retirar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	DECLARE @estado BINARY; SELECT @estado = estado FROM inserted
	UPDATE registro.inscripciones_individual
	SET estado = @estado
	WHERE id = @id
END;
GO
GO
CREATE TRIGGER ELIMINAR_PARTICIPANTE_EVENTO_IND
ON registro.inscripciones_individual
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @id INT; SELECT @id = id FROM deleted
	DECLARE @id_evento INT; SELECT @id_evento = id_evento FROM deleted
	IF((SELECT fecha_inicio FROM evento.eventos WHERE id = @id_evento) <= GETDATE())
	BEGIN
		RAISERROR('Evento ya finalizado/iniciado, no se puede retirar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	UPDATE registro.inscripciones_individual
	SET estado = 0
	WHERE id = @id
END;
GO



--INSERTAR INSCRIPCION DE PARTICIPANTE_EVENTO (GRUPO)

GO
CREATE TRIGGER ENTRAR_EVENTO_GRUPO
ON registro.inscripciones_equipo
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @id_evento INT; SELECT @id_evento = id_evento FROM inserted
	DECLARE @id_equipo INT; SELECT @id_equipo = id_equipo from inserted
	IF((SELECT COUNT(ID) FROM registro.inscripciones_equipo WHERE id_evento = @id_evento AND estado = 1)>= (select max_miembros from evento.eventos where id = @id_evento)
	AND (select max_miembros from evento.eventos where id = @id_evento) != null)
	BEGIN
		RAISERROR('Evento Completo, no se pudo ingresar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT estado FROM evento.eventos WHERE id = @id_evento) = 0)
	BEGIN
		RAISERROR('Evento no existe, no se pudo ingresar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT COUNT(ID) FROM persona.participantes WHERE id_equipo = @id_equipo AND estado = 1) = (select max_miembros_equipos from evento.eventos where id = @id_evento)
	AND (select max_miembros_equipos from evento.eventos where id = @id_evento) != null)
	BEGIN
		RAISERROR('Miembros no suficientes en su quipo para el evento, no se pudo ingresar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT fecha_fin FROM evento.eventos WHERE id = @id_evento) < GETDATE())
	BEGIN
		RAISERROR('Evento ya finalizado, no se puede ingresar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT fecha_inicio FROM evento.eventos WHERE id = @id_evento) < GETDATE())
	BEGIN
		RAISERROR('Evento ya iniciado, no se puede ingresar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE
	BEGIN
	   INSERT INTO registro.inscripciones_equipo(id_equipo, id_evento, estado, fecha_inscripcion)
	   VALUES(@id_equipo, @id_evento, 1, GETDATE())
	END
END;
GO
GO
CREATE TRIGGER MODIFICAR_PARTICIANTES_EVENTO_GRUPO
ON registro.inscripciones_equipo
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @id INT; SELECT @id = id FROM deleted
	DECLARE @id_evento INT; SELECT @id_evento = id_evento FROM deleted

	IF((SELECT fecha_inicio FROM evento.eventos WHERE id = @id_evento) <= GETDATE())
	BEGIN
		RAISERROR('Evento ya finalizado/iniciado, no se puede retirar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE
	BEGIN
		DECLARE @estado BINARY; SELECT @estado = estado FROM inserted
		UPDATE registro.inscripciones_equipo
		SET estado = @estado
	WHERE id = @id
	END
	
END;
GO
GO
CREATE TRIGGER ELIMINAR_PARTICIPANTE_EVENTO_GRUPO
ON registro.inscripciones_equipo
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @id INT; SELECT @id = id FROM deleted
	DECLARE @id_evento INT; SELECT @id_evento = id_evento FROM deleted

	IF((SELECT fecha_inicio FROM evento.eventos WHERE id = @id_evento) <= GETDATE())
	BEGIN
		RAISERROR('Evento ya finalizado/iniciado, no se puede retirar.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	UPDATE registro.inscripciones_equipo
	SET estado = 0
	WHERE id = @id
END;
GO



--INSERTAR CERTIFICADO (IND)

GO
CREATE TRIGGER ENVIAR_CERTIFICADO_IND
ON registro.certificado_individual
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @id_inscripcion_individual INT; SELECT @id_inscripcion_individual = id_inscripcion_individual FROM inserted
	DECLARE @id_evento INT; SELECT @id_evento = id_evento FROM registro.inscripciones_individual WHERE id = @id_inscripcion_individual
	IF((SELECT estado FROM evento.eventos WHERE id = @id_evento) = 0)
	BEGIN
		RAISERROR('Evento no existe, no se pudo entregar el certificado.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT estado FROM registro.inscripciones_individual WHERE id = @id_inscripcion_individual) = 0)
	BEGIN
		RAISERROR('Inscripcion cancelada, no se pudo entregar el certificado.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT fecha_fin FROM evento.eventos WHERE id = @id_evento) > GETDATE())
	BEGIN
		RAISERROR('Evento aun no finalizado, no se puede entregar certificado.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT fecha_inicio FROM evento.eventos WHERE id = @id_evento) > GETDATE())
	BEGIN
		RAISERROR('Evento aun no iniciado, no se puede entregar certificado.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE
	BEGIN
		DECLARE @archivo VARCHAR(255); SELECT @archivo = archivo FROM inserted
	   INSERT INTO registro.certificado_individual(id_inscripcion_individual, fecha_emision, archivo)
	   VALUES(@id_inscripcion_individual, GETDATE(), @archivo)
	END
END;
GO

--INSERTAR CERTIFICADO (GRUPO)

GO
CREATE TRIGGER ENVIAR_CERTIFICADO_GRUPO
ON registro.certificado_equipos
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @id_inscripcion_grupal INT; SELECT @id_inscripcion_grupal = id_inscripcion_equipo FROM inserted
	DECLARE @id_evento INT; SELECT @id_evento = id_evento FROM registro.inscripciones_equipo WHERE id = @id_inscripcion_grupal
	DECLARE @id_equipo INT; SELECT @id_equipo = id_equipo FROM registro.inscripciones_equipo WHERE id = @id_inscripcion_grupal
	IF((SELECT estado FROM evento.eventos WHERE id = @id_evento) = 0)
	BEGIN
		RAISERROR('Evento no existe, no se pudo entregar el certificado.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT estado FROM registro.inscripciones_equipo WHERE id = @id_inscripcion_grupal) = 0)
	BEGIN
		RAISERROR('Inscripcion cancelada, no se pudo entregar el certificado.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT fecha_fin FROM evento.eventos WHERE id = @id_evento) > GETDATE())
	BEGIN
		RAISERROR('Evento aun no finalizado, no se puede entregar certificado.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE IF((SELECT fecha_inicio FROM evento.eventos WHERE id = @id_evento) > GETDATE())
	BEGIN
		RAISERROR('Evento aun no iniciado, no se puede entregar certificado.', 16, 1)
		ROLLBACK TRANSACTION;
	END
	ELSE
	BEGIN
		DECLARE @id_usuario INT; DECLARE @cantidad_inscritos INT;
		SELECT @cantidad_inscritos = COUNT(id) FROM persona.participantes WHERE id_equipo = @id_equipo AND estado = 1;
		DECLARE @archivo VARCHAR(255); SELECT @archivo = archivo FROM inserted

		WHILE(@cantidad_inscritos > 0)
		BEGIN
			WITH participantes_equipo AS (SELECT id_usuario, ROW_NUMBER() OVER (ORDER BY id DESC) AS RowNum
			FROM persona.participantes WHERE id_equipo = @id_equipo AND estado = 1)

			SELECT @id_usuario = (SELECT id_usuario FROM participantes_equipo WHERE RowNum = @cantidad_inscritos);

			INSERT INTO registro.certificado_equipos(id_inscripcion_equipo,id_usuario, fecha_emision, archivo)
			VALUES(@id_inscripcion_grupal, @id_usuario, GETDATE(), @archivo)

			SELECT @cantidad_inscritos = @cantidad_inscritos - 1
		END
	END
END;
GO