import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { CreateTenantDto, TenantDto, AddUserDto, WorkspaceDto, CreateWorkspaceDto, DatasetDto, CreateDatasetDto, UpdateDatasetDto, CreateUserDto, UserDto } from '@salvachll/shared/domain';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private readonly http = inject(HttpClient);

  // ------------------ USER ENDPOINTS ------------------

  // Register a new user
  registerUser(): Observable<UserDto> {
    return this.http.post<UserDto>(`/api/v1/user`, {});
  }

  // List all users
  getAllUsers(): Observable<UserDto[]> {
    return this.http.get<UserDto[]>(`/api/v1/user`);
  }

  // Get details of a specific user by ID
  getUserById(userId: string): Observable<UserDto> {
    return this.http.get<UserDto>(`/api/v1/user/${userId}`);
  }

  // Get current logged-in user info
  getCurrentUserInfo(): Observable<UserDto> {
    return this.http.get<UserDto>(`/api/v1/user/info`);
  }

  // ------------------ TENANT ENDPOINTS ------------------

  getAllTenants(): Observable<TenantDto[]> {
    return this.http.get<TenantDto[]>(`/api/v1/tenant`);
  }

  getTenantById(tenantId: string): Observable<TenantDto> {
    return this.http.get<TenantDto>(`/api/v1/tenant/${tenantId}`);
  }

  createTenant(tenantData: CreateTenantDto): Observable<TenantDto> {
    return this.http.post<TenantDto>(`/api/v1/tenant`, tenantData);
  }

  addUserToTenant(tenantId: string, userData: AddUserDto): Observable<TenantDto> {
    return this.http.post<TenantDto>(`/api/v1/tenant/${tenantId}/addUser`, userData);
  }

  // ------------------ WORKSPACE ENDPOINTS ------------------

  createWorkspace(workspaceData: CreateWorkspaceDto): Observable<WorkspaceDto> {
    return this.http.post<WorkspaceDto>(`/api/v1/workspace`, workspaceData);
  }

  getWorkspaceById(workspaceId: string): Observable<WorkspaceDto> {
    return this.http.get<WorkspaceDto>(`/api/v1/workspace/${workspaceId}`);
  }

  deleteWorkspace(workspaceId: string): Observable<void> {
    return this.http.delete<void>(`/api/v1/workspace/${workspaceId}/delete`);
  }

  getWorkspacesByTenant(tenantId: string): Observable<WorkspaceDto[]> {
    return this.http.get<WorkspaceDto[]>(`/api/v1/workspace/tenant/${tenantId}`);
  }

  // ------------------ DATASET ENDPOINTS ------------------

  createDataset(datasetData: CreateDatasetDto): Observable<DatasetDto> {
    return this.http.post<DatasetDto>(`/api/v1/dataset`, datasetData);
  }

  getDatasetById(datasetId: string): Observable<DatasetDto> {
    return this.http.get<DatasetDto>(`/api/v1/dataset/${datasetId}`);
  }

  updateDataset(datasetId: string, datasetData: UpdateDatasetDto): Observable<DatasetDto> {
    return this.http.patch<DatasetDto>(`/api/v1/dataset/${datasetId}`, datasetData);
  }

  getDatasetsByTenant(tenantId: string): Observable<DatasetDto[]> {
    return this.http.get<DatasetDto[]>(`/api/v1/dataset/tenant/${tenantId}`);
  }
}
