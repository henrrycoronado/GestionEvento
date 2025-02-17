using System;
using System.Collections.Generic;

namespace GESTION_EVENTO.AppService.Models;

public partial class Evento
{
    public int Id { get; set; }

    public int IdAdministrador { get; set; }

    public string? Nombre { get; set; }

    public string? Descripcion { get; set; }

    public string? Ubicacion { get; set; }

    public string? InformacionContacto { get; set; }

    public DateTime FechaInicio { get; set; }

    public DateTime FechaFin { get; set; }

    public bool Tipo { get; set; }

    public bool Estado { get; set; }

    public DateTime FechaCreacion { get; set; }

    public bool Certificados { get; set; }
}
