import { Component, Input, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { WorkspaceDto, CreateWorkspaceDto } from '@salvachll/shared/domain';
import { ApiService } from '@salvachll/client/data-access';
import { catchError } from 'rxjs/operators';
import { of } from 'rxjs';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'lib-workspace',
  standalone: true,
  templateUrl: './workspace.component.html',
  styleUrls: ['./workspace.component.scss'],
  imports: [CommonModule, ReactiveFormsModule]
})
export class WorkspaceComponent implements OnInit {
  @Input() tenantId!: string;
  workspaces: WorkspaceDto[] = [];
  selectedWorkspace?: WorkspaceDto;
  workspaceForm: FormGroup;
  errorMessage = '';
  loading = false;  // Add a loading flag

  tools = ['vscode', 'grafana', 'airflow', 'manager'];

  constructor(private apiService: ApiService, private fb: FormBuilder) {
    this.workspaceForm = this.fb.group({
      id: ['']
    });
  }

  ngOnInit(): void {
    this.loadWorkspaces();
  }

  loadWorkspaces() {
    this.apiService.getWorkspacesByTenant(this.tenantId).pipe(
      catchError(err => {
        console.error('Failed to load workspaces:', err);
        this.errorMessage = 'Failed to load workspaces';
        return of([]);
      })
    ).subscribe(workspaces => this.workspaces = workspaces);
  }

  createWorkspace() {
    this.loading = true;  // Set loading to true when form is submitted
    const workspaceData: CreateWorkspaceDto = {
      id: this.workspaceForm.value.id,
      tenantId: this.tenantId,
    };

    this.apiService.createWorkspace(workspaceData).pipe(
      catchError(err => {
        console.error('Failed to create workspace:', err);
        this.errorMessage = 'Failed to create workspace';
        this.loading = false;  // Stop loading on error
        return of(undefined);
      })
    ).subscribe(newWorkspace => {
      if (newWorkspace) {
        this.workspaces.push(newWorkspace);
        this.workspaceForm.reset();
      }
      this.loading = false;  // Stop loading after the workspace is created
    });
  }

  loadWorkspaceDetails(workspaceId: string) {
    this.apiService.getWorkspaceById(workspaceId).pipe(
      catchError(err => {
        console.error('Failed to load workspace details:', err);
        this.errorMessage = 'Failed to load workspace details';
        return of(undefined);
      })
    ).subscribe(workspace => this.selectedWorkspace = workspace);
  }

  deleteWorkspace(workspaceId: string) {
    this.apiService.deleteWorkspace(workspaceId).pipe(
      catchError(err => {
        console.error('Failed to delete workspace:', err);
        this.errorMessage = 'Failed to delete workspace';
        return of(undefined);
      })
    ).subscribe(() => {
      this.workspaces = this.workspaces.filter(workspace => workspace.id !== workspaceId);
      this.selectedWorkspace = undefined;
    });
  }
}
