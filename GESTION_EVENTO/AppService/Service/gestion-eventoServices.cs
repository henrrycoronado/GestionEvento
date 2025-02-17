using GESTION_EVENTO.AppService.Models;
using System.Collections.Generic;
using System.Linq;

public class GestionEventoServices
{
    public List<Evento> GetEventosDisponibles(List<Evento> eventos)
    {
        return eventos.Where(e => e.Estado && e.FechaInicio >= DateTime.Now).ToList();
    }

    public List<Evento> GetDetalleEventoId(List<Evento> eventos, int id_evento)
    {
        return eventos.Where(e => e.Estado && e.Id == id_evento).ToList();
    }

    public List<Evento> GetDetalleEventoName(List<Evento> eventos, string nombre)
    {
        return eventos.Where(e => e.Estado && e.Nombre == nombre).ToList();
    }
}
