import { Component, Input, OnInit } from '@angular/core';
import { DatasetDto, CreateDatasetDto, UpdateDatasetDto } from '@salvachll/shared/domain';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { catchError } from 'rxjs/operators';
import { of } from 'rxjs';
import { CommonModule } from '@angular/common';
import { NgbAlertModule } from '@ng-bootstrap/ng-bootstrap';
import { ApiService } from '@salvachll/client/data-access';

@Component({
  selector: 'lib-dataset',
  standalone: true,
  templateUrl: './dataset.component.html',
  styleUrls: ['./dataset.component.scss'],
  imports: [CommonModule, NgbAlertModule, ReactiveFormsModule],
})
export class DatasetComponent implements OnInit {
  @Input() tenantId!: string; // Tenant ID is passed down from the parent component
  datasets: DatasetDto[] = [];
  selectedDataset?: DatasetDto;
  datasetForm: FormGroup;
  updateDatasetForm: FormGroup;
  errorMessage = '';

  constructor(private apiService: ApiService, private fb: FormBuilder) {
    // Initialize the forms
    this.datasetForm = this.fb.group({
      datasetName: [''],
      metadata: ['']
    });

    this.updateDatasetForm = this.fb.group({
      datasetName: [''],
      metadata: ['']
    });
  }

  ngOnInit(): void {
    this.loadDatasets();
  }

  // Fetch all datasets for a tenant
  loadDatasets() {
    this.apiService.getDatasetsByTenant(this.tenantId).pipe(
      catchError(err => {
        console.error('Failed to load datasets:', err);
        this.errorMessage = 'Failed to load datasets';
        return of([]);
      })
    ).subscribe(datasets => this.datasets = datasets);
  }

  // Fetch dataset details by ID
  loadDatasetDetails(datasetId: string) {
    this.apiService.getDatasetById(datasetId).pipe(
      catchError(err => {
        console.error('Failed to load dataset details:', err);
        this.errorMessage = 'Failed to load dataset details';
        return of(undefined);
      })
    ).subscribe(dataset => {
      if (dataset) {
        this.selectedDataset = dataset;
        this.updateDatasetForm.patchValue({
          datasetName: dataset.datasetName,
          metadata: dataset.metadata
        });
      }
    });
  }

  // Create a new dataset
  createDataset() {
    const datasetData: CreateDatasetDto = {
      ...this.datasetForm.value,
      tenantId: this.tenantId,
      createdByUserId: 'current-user-id', // Replace with actual logic to get the current user
    };
    this.apiService.createDataset(datasetData).pipe(
      catchError(err => {
        console.error('Failed to create dataset:', err);
        this.errorMessage = 'Failed to create dataset';
        return of(undefined);
      })
    ).subscribe(newDataset => {
      if (newDataset) {
        this.datasets.push(newDataset);
        this.datasetForm.reset(); // Clear the form after submission
      }
    });
  }

  // Update an existing dataset
  updateDataset(datasetId: string) {
    const datasetData: UpdateDatasetDto = this.updateDatasetForm.value;
    this.apiService.updateDataset(datasetId, datasetData).pipe(
      catchError(err => {
        console.error('Failed to update dataset:', err);
        this.errorMessage = 'Failed to update dataset';
        return of(undefined);
      })
    ).subscribe(updatedDataset => {
      if (updatedDataset) {
        this.loadDatasets(); // Reload datasets after update
        this.updateDatasetForm.reset(); // Clear the form after submission
      }
    });
  }
}
