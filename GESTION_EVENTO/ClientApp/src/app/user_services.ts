import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private userIDSource = new BehaviorSubject<number>(0);
  userID$ = this.userIDSource.asObservable();

  constructor() { }

  setUserID(userID: number) {
    this.userIDSource.next(userID);
  }
}
