import { Component } from '@angular/core';

@Component({
  selector: 'app-perfil',
  templateUrl: './perfil.component.html',
  styleUrls: ['./perfil.component.css']
})
export class PerfilComponent {
  currentDate = new Date();
  currentMonth = this.currentDate.getMonth();
  currentYear = this.currentDate.getFullYear();
  today = this.currentDate.getDate();  // Día actual

  constructor() { }

  getMonthName(): string {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio',
                    'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[this.currentMonth];
  }

  getDaysInMonth(): number {
    return new Date(this.currentYear, this.currentMonth + 1, 0).getDate();
  }

  getFirstDayOfMonth(): number {
    return new Date(this.currentYear, this.currentMonth, 1).getDay();
  }

  isToday(day: number): boolean {
    return this.currentMonth === this.currentDate.getMonth() &&
           this.currentYear === this.currentDate.getFullYear() &&
           day === this.today;
  }
}
