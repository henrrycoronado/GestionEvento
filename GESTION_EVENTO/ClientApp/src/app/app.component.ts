import { Component } from '@angular/core';
import { UserService } from './user_services';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
})
export class AppComponent {
  public ID:Number = 1;

  constructor(private userService: UserService) {
    this.userService.userID$.subscribe(userID => {
      this.ID = userID;
    });
  }
}
