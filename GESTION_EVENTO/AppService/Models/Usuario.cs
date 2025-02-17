using System;
using System.Collections.Generic;

namespace GESTION_EVENTO.AppService.Models;

public partial class Usuario
{
    public int Id { get; set; }

    public string? Nombre { get; set; }

    public string? Direccion { get; set; }

    public DateTime FechaNacimiento { get; set; }

    public string? Correo { get; set; }

    public string? Telefono { get; set; }

    public string? Organizacion { get; set; }

    public string? Profesion { get; set; }

    public string? Cargo { get; set; }

    public string? UserPassword { get; set; }

    public DateTime FechaCreacion { get; set; }

}
