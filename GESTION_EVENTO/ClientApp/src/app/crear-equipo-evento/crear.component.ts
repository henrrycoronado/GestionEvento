// atm-detail.component.ts
import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Component({
  selector: 'app-crear',
  templateUrl: './crear.component.html',
  styleUrls: ['./crear.component.css']
})
export class CrearComponent implements OnInit {
  atms: any[] = [];  // Asumiendo que la respuesta es un array, ajusta según el modelo de datos

  constructor(private http: HttpClient){
    
  }

  ngOnInit(): void {
    this.loadAtmDetails();
  }

  loadAtmDetails(): void {
    this.http.get<any[]>('/Atmdetail').subscribe(
      data => {
        this.atms = data;
      },
      error => {
        console.error('There was an error!', error);
      }
    );
  }
}
