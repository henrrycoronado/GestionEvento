using System;
using System.Collections.Generic;

namespace GESTION_EVENTO.AppService.Models;

public partial class InscripcionesIndividual
{
    public int Id { get; set; }

    public int IdEvento { get; set; }

    public int IdUsuario { get; set; }

    public DateTime FechaInscripcion { get; set; }

    public bool Estado { get; set; }

    public bool Certificado { get; set; }

    public DateTime? FechaEntrega { get; set; }

}
