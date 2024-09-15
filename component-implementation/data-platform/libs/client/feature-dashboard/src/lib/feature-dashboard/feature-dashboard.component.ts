import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '@salvachll/client/data-access'
import { TenantComponent, UserInfoComponent } from '@salvachll/client/ui-components'

@Component({
  selector: 'lib-feature-dashboard',
  standalone: true,
  imports: [CommonModule, UserInfoComponent, TenantComponent],
  templateUrl: './feature-dashboard.component.html',
  styleUrl: './feature-dashboard.component.scss',
})
export class FeatureDashboardComponent {
  private readonly apiService = inject(ApiService);

}
