using System;
using System.Collections.Generic;

namespace GESTION_EVENTO.AppService.Models;

public partial class Participante
{
    public int Id { get; set; }

    public int IdUsuario { get; set; }

    public int IdEquipo { get; set; }

    public bool Estado { get; set; }

}
