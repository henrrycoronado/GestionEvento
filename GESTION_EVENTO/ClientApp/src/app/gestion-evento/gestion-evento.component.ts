import { Component } from '@angular/core';

@Component({
  selector: 'app-gestion-evento',
  templateUrl: './gestion-evento.component.html',
  styleUrls: ['./gestion-evento.component.css']
})
export class GestionEventoComponent {
  public currentCount = 0;

  public incrementCounter() {
    this.currentCount++;
  }
}
