import { Component, OnInit } from '@angular/core';
import { EventoService } from './evento.servicio';
import { Evento } from './evento.servicio';
import { Observable } from 'rxjs';

@Component({
  selector: 'app-evento',
  templateUrl: './evento.component.html',
  styleUrls: ['./evento.component.css']
})
export class EventoComponent implements OnInit {
  public eventos: Evento[] = [];
  public selectedEvento?: Evento;
  public name: string = "";
  public id: number | null = null;

  constructor(private eventoService: EventoService) {}

  ngOnInit(): void {
    this.loadEventos();
  }

  loadEventos(): void {
    this.eventoService.getEventosDisponibles().subscribe((data: Evento[]) => {
      this.eventos = data;
      console.log('Eventos disponibles:', this.eventos);
    }, error => console.error(error));
  }

  selectEvento(evento: Evento): void {
    this.selectedEvento = evento;
    console.log('Selected event:', this.selectedEvento);
  }

  buscarPorNombre(): void {
    if (this.name) {
      this.eventoService.getDetalleEventoName(this.name).subscribe((data: Evento[]) => {
        if (data.length > 0) {
          this.selectedEvento = data[0];
          console.log('Event fetched by name:', this.selectedEvento);
        } else {
          console.log('No events found with the given name');
        }
      }, error => console.error(error));
    }
  }

  buscarPorId(): void {
    if (this.id !== null && !isNaN(this.id)) {
      this.eventoService.getDetalleEventoId(this.id).subscribe((data: Evento) => {
        this.selectedEvento = data;
        console.log('Event fetched by ID:', this.selectedEvento);
      }, error => console.error(error));
    }
  }
}
