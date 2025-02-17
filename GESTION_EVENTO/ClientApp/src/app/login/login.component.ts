import { Component, Inject } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { UserService } from '../user_services';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  public ID: number = 0;
  public email: string = '';
  public contra: string = '';

  constructor(
    private http: HttpClient,
    @Inject('BASE_URL') private baseUrl: string,
    private userService: UserService
  ) { }

  onLoginClick() {
    this.iniciarSesion(this.email, this.contra);
  }

  iniciarSesion(email: string, contra: string) {
    const headers = new HttpHeaders({ 'Content-Type': 'application/json' });
    const body = { email: email, contra: contra };

    this.http.post<number>(`${this.baseUrl}/Usuario/IniciarSesion`, body, { headers })
      .subscribe({
        next: (response) => {
          this.ID = response;
          if (this.ID !== 0) {
            this.userService.setUserID(this.ID);
          }
        },
        error: (error) => {
          console.error('Error al iniciar sesión:', error);
        }
      });
  }
}
