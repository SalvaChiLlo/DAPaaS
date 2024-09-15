import { Component, OnInit } from '@angular/core';
import { TenantDto, CreateTenantDto, AddUserDto } from '@salvachll/shared/domain';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { catchError } from 'rxjs/operators';
import { of } from 'rxjs';
import { CommonModule } from '@angular/common';
import { NgbAlertModule } from '@ng-bootstrap/ng-bootstrap';
import { ApiService } from '@salvachll/client/data-access';
import { DatasetComponent } from '../dataset/dataset.component';
import { WorkspaceComponent } from "../workspace/workspace.component";  // Import the DatasetComponent

@Component({
  selector: 'lib-tenant',
  standalone: true,
  templateUrl: './tenant.component.html',
  styleUrls: ['./tenant.component.scss'],
  imports: [CommonModule, NgbAlertModule, ReactiveFormsModule, DatasetComponent, WorkspaceComponent], // Add DatasetComponent to imports
})
export class TenantComponent implements OnInit {
  tenants: TenantDto[] = [];
  selectedTenant?: TenantDto;
  tenantForm: FormGroup;
  addUserForm: FormGroup;
  errorMessage = '';
  tenantDetailsVisible = false;
  tenantDatasetsVisible = false;
  tenantWorkspacesVisible = false;

  constructor(private apiService: ApiService, private fb: FormBuilder) {
    // Initialize the forms
    this.tenantForm = this.fb.group({
      id: ['']
    });

    this.addUserForm = this.fb.group({
      userId: [''],
      role: ['']
    });
  }

  ngOnInit(): void {
    this.loadTenants();
  }

  toggleTenantDetails() {
    this.tenantDetailsVisible = !this.tenantDetailsVisible;
  }

  toggleTenantDatasets() {
    this.tenantDatasetsVisible = !this.tenantDatasetsVisible;
  }

  toggleTenantWorkspaces() {
    this.tenantWorkspacesVisible = !this.tenantWorkspacesVisible;
  }

  // Fetch all tenants
  loadTenants() {
    this.apiService.getAllTenants().pipe(
      catchError(err => {
        console.error('Failed to load tenants:', err);
        this.errorMessage = 'Failed to load tenants';
        return of([]);
      })
    ).subscribe(tenants => this.tenants = tenants);
  }

  // Fetch tenant details by ID
  loadTenantDetails(tenantId: string) {
    this.apiService.getTenantById(tenantId).pipe(
      catchError(err => {
        console.error('Failed to load tenant details:', err);
        this.errorMessage = 'Failed to load tenant details';
        return of(undefined);
      })
    ).subscribe(tenant => this.selectedTenant = tenant);
  }

  // Create a new tenant
  createTenant() {
    const tenantData: CreateTenantDto = this.tenantForm.value;
    this.apiService.createTenant(tenantData).pipe(
      catchError(err => {
        console.error('Failed to create tenant:', err);
        this.errorMessage = 'Failed to create tenant';
        return of(undefined);
      })
    ).subscribe(newTenant => {
      if (newTenant) {
        this.tenants.push(newTenant);
        this.tenantForm.reset(); // Clear the form after submission
      }
    });
  }

  // Add a user to a tenant
  addUserToTenant(tenantId: string) {
    const userData: AddUserDto = this.addUserForm.value;
    this.apiService.addUserToTenant(tenantId, userData).pipe(
      catchError(err => {
        console.error('Failed to add user to tenant:', err);
        this.errorMessage = 'Failed to add user to tenant';
        return of(undefined);
      })
    ).subscribe(updatedTenant => {
      if (updatedTenant) {
        this.selectedTenant = updatedTenant;
        this.addUserForm.reset(); // Clear the form after submission
      }
    });
  }
}
