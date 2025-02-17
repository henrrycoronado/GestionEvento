import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { RouterModule } from '@angular/router';

import { AppComponent } from './app.component';
import { NavMenuComponent } from './nav-menu/nav-menu.component';
import { NavMenu2Component } from './nav-menu2/nav-menu2.component';
import { EventoComponent } from './ver-eventos/evento.component';
import { GestionEventoComponent } from './gestion-evento/gestion-evento.component';
import { PerfilComponent } from './perfil/perfil.component';
import { CrearComponent } from './crear-equipo-evento/crear.component';
import { EquipoComponent } from './ver-equipos/equipo.component';
import { LoginComponent } from './login/login.component';
import { RegistroComponent } from './registro/registro.component';
import { GestionEquipoComponent } from './gestion-equipos/gestion-equipos.component';
import { HistorialComponent } from './historial/historial.component';


@NgModule({
  declarations: [
    AppComponent,
    NavMenuComponent,
    NavMenu2Component,
    PerfilComponent,
    EventoComponent,
    EquipoComponent,
    GestionEventoComponent,
    GestionEquipoComponent,
    CrearComponent,
    HistorialComponent,
    LoginComponent,
    RegistroComponent
  ],
  imports: [
    BrowserModule.withServerTransition({ appId: 'ng-cli-universal' }),
    HttpClientModule,
    FormsModule,
    RouterModule.forRoot([
      { path: '', component: PerfilComponent, pathMatch: 'full' },
      { path: 'evento', component: EventoComponent },
      { path: 'equipo', component: EquipoComponent },
      { path: 'gestion-evento', component: GestionEventoComponent },
      { path: 'gestion-equipo', component: GestionEquipoComponent },
      { path: 'crear', component: CrearComponent },
      { path: 'historial', component: HistorialComponent },
      { path: 'login', component: LoginComponent},
      {path: 'registro', component: RegistroComponent}
    ])
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
