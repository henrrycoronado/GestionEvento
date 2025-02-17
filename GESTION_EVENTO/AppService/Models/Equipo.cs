using System;
using System.Collections.Generic;

namespace GESTION_EVENTO.AppService.Models;

public partial class Equipo
{
    public int Id { get; set; }

    public string? Nombre { get; set; }

    public int? MiembrosMax { get; set; }

    public string? Institucion { get; set; }

    public int RepresentanteId { get; set; }

    public bool Estado { get; set; }

    public bool Tipo { get; set; }

    public DateTime FechaCreacion { get; set; }

}
