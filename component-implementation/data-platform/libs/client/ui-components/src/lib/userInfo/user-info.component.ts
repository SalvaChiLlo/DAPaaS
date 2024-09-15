import { Component, OnInit } from '@angular/core';
import { UserDto } from '@salvachll/shared/domain';
import { catchError, switchMap } from 'rxjs/operators';
import { of } from 'rxjs';
import { ApiService } from '@salvachll/client/data-access';
import { CommonModule } from '@angular/common';
import { NgbAlertModule } from '@ng-bootstrap/ng-bootstrap';

@Component({
  selector: 'lib-user-info',
  standalone: true,
  templateUrl: './user-info.component.html',
  styleUrls: ['./user-info.component.scss'],
  imports: [CommonModule, NgbAlertModule],
})
export class UserInfoComponent implements OnInit {
  userInfo?: UserDto;
  errorMessage = '';

  constructor(private apiService: ApiService) { }

  ngOnInit(): void {
    this.loadUserInfo();
  }

  loadUserInfo() {
    this.apiService.getCurrentUserInfo().pipe(
      // If the request to get the user fails, try to register a new user
      catchError(() => {
        console.error('User info not found. Attempting to register the user.');
        return this.apiService.registerUser(); // Try to create the user
      })
    ).subscribe({
      next: (user) => {
        this.userInfo = user; // Set the user info once it's available
      },
      error: (err) => {
        console.error('Failed to register or retrieve user info:', err);
        this.errorMessage = 'Failed to load user information.';
      }
    });
  }
}
