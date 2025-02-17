using Microsoft.AspNetCore.Mvc;
using GESTION_EVENTO.AppService.Models;
using System.Collections.Generic;
using System.Linq;

namespace GESTION_DE_EVENTO.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class GestionEventoController : ControllerBase
    {
        public List<Evento> eventos = new List<Evento>
        {
            new Evento
            {
                Id = 1,
                IdAdministrador = 101,
                Nombre = "Evento A",
                Descripcion = "Descripción del Evento A",
                Ubicacion = "Ubicación A",
                InformacionContacto = "Contacto A",
                FechaInicio = DateTime.Now.AddDays(10),
                FechaFin = DateTime.Now.AddDays(12),
                Tipo = true,
                Estado = true,
                FechaCreacion = DateTime.Now,
                Certificados = true
            },
            new Evento
            {
                Id = 2,
                IdAdministrador = 102,
                Nombre = "Evento B",
                Descripcion = "Descripción del Evento B",
                Ubicacion = "Ubicación B",
                InformacionContacto = "Contacto B",
                FechaInicio = DateTime.Now.AddDays(20),
                FechaFin = DateTime.Now.AddDays(22),
                Tipo = false,
                Estado = false,
                FechaCreacion = DateTime.Now,
                Certificados = false
            },
            new Evento
            {
                Id = 3,
                IdAdministrador = 103,
                Nombre = "Evento C",
                Descripcion = "Descripción del Evento C",
                Ubicacion = "Ubicación C",
                InformacionContacto = "Contacto C",
                FechaInicio = DateTime.Now.AddDays(30),
                FechaFin = DateTime.Now.AddDays(32),
                Tipo = true,
                Estado = true,
                FechaCreacion = DateTime.Now,
                Certificados = true
            }
        };

        public GestionEventoServices EventoServices = new GestionEventoServices();

        [HttpGet("evento-disponible")]
        public IEnumerable<Evento> GetEventosDisponibles()
        {
            return EventoServices.GetEventosDisponibles(eventos);
        }

        [HttpGet("detalle-evento-id")]
        public IEnumerable<Evento> GetDetalleEventoId([FromQuery] int id_evento)
        {
            return EventoServices.GetDetalleEventoId(eventos, id_evento);
        }

        [HttpGet("detalle-evento-name")]
        public IEnumerable<Evento> GetDetalleEventoName([FromQuery] string name_evento)
        {
            return EventoServices.GetDetalleEventoName(eventos, name_evento);
        }
    }
}
