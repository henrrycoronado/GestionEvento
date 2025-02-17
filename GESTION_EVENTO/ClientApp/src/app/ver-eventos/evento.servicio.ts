import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Evento {
  Id: number;
  IdAdministrador: number;
  Nombre: string;
  Descripcion: string;
  Ubicacion: string;
  InformacionContacto: string;
  FechaInicio: Date;
  FechaFin: Date;
  Tipo: boolean;
  Estado: boolean;
  FechaCreacion: Date;
  Certificados: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class EventoService {
  private baseUrl = 'http://localhost:44403/GestionEvento';

  constructor(private http: HttpClient) {}

  getEventosDisponibles(): Observable<Evento[]> {
    return this.http.get<Evento[]>(`${this.baseUrl}/evento-disponible`);
  }

  getDetalleEventoId(id: number): Observable<Evento> {
    return this.http.get<Evento>(`${this.baseUrl}/detalle-evento-id?id_evento=${id}`);
  }

  getDetalleEventoName(name: string): Observable<Evento[]> {
    return this.http.get<Evento[]>(`${this.baseUrl}/detalle-evento-name?name_evento=${name}`);
  }
}
