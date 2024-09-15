import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DatasetEntitySchema, TenantEntitySchema, UserEntitySchema, TenantUserEntitySchema } from '@salvachll/server/data-access';
import { Repository } from 'typeorm';
import { DatasetDto, CreateDatasetDto, UpdateDatasetDto, AuthorizationHeader } from '@salvachll/shared/domain';

@Injectable()
export class ServerFeatureDatasetService {
  constructor(
    @InjectRepository(DatasetEntitySchema)
    private datasetRepository: Repository<DatasetEntitySchema>,
    @InjectRepository(TenantEntitySchema)
    private tenantRepository: Repository<TenantEntitySchema>,
    @InjectRepository(UserEntitySchema)
    private userRepository: Repository<UserEntitySchema>,
    @InjectRepository(TenantUserEntitySchema)
    private tenantUserRepository: Repository<TenantUserEntitySchema>
  ) { }

  // Validate that the user is a member of the tenant
  private async ensureUserIsTenantMember(userId: string, tenantId: string): Promise<void> {
    const tenantUser = await this.tenantUserRepository.findOne({
      where: { user: { id: userId }, tenant: { id: tenantId } },
    });

    if (!tenantUser) {
      throw new ForbiddenException('You are not authorized to perform this action.');
    }
  }

  // Create a new dataset
  async createDataset(data: CreateDatasetDto, auth: AuthorizationHeader): Promise<DatasetDto> {
    const userId = auth.federated_claims.user_id;
    const tenant = await this.tenantRepository.findOne({ where: { id: data.tenantId } });
    const user = await this.userRepository.findOne({ where: { id: userId } });

    if (!tenant) {
      throw new NotFoundException(`Tenant with ID '${data.tenantId}' not found.`);
    }
    if (!user) {
      throw new NotFoundException(`User with ID '${userId}' not found.`);
    }

    // Ensure the requestor is a member of the tenant before creating the dataset
    await this.ensureUserIsTenantMember(userId, data.tenantId);

    const dataset = this.datasetRepository.create({
      datasetName: data.datasetName,
      tenant,
      createdByUser: user,
      metadata: data.metadata,
    });

    await this.datasetRepository.save(dataset);
    return dataset;
  }

  // Get dataset details
  async getDataset(id: string, auth: AuthorizationHeader): Promise<DatasetDto> {
    const dataset = await this.datasetRepository.findOne({
      where: { id },
      relations: ['tenant', 'createdByUser'],
    });
    const userId = auth.federated_claims.user_id;

    if (!dataset) {
      throw new NotFoundException(`Dataset with ID '${id}' not found.`);
    }

    // Ensure the requestor is a member of the tenant before retrieving the dataset
    await this.ensureUserIsTenantMember(userId, dataset.tenant.id);

    return dataset;
  }

  // Update dataset
  async updateDataset(datasetId: string, data: UpdateDatasetDto, auth: AuthorizationHeader): Promise<DatasetDto> {
    const dataset = await this.getDataset(datasetId, auth);
    const userId = auth.federated_claims.user_id;

    // Ensure the requestor is a member of the tenant before updating the dataset
    await this.ensureUserIsTenantMember(userId, dataset.tenantId);

    const updatedDataset = Object.assign(dataset, data);
    await this.datasetRepository.save(updatedDataset);
    return updatedDataset;
  }

  // List datasets by tenant
  async listDatasetsByTenant(tenantId: string, auth: AuthorizationHeader): Promise<DatasetDto[]> {
    const userId = auth.federated_claims.user_id;

    // Ensure the requestor is a member of the tenant before listing datasets
    await this.ensureUserIsTenantMember(userId, tenantId);

    const datasets = await this.datasetRepository.find({
      where: { tenant: { id: tenantId } },
      relations: ['tenant', 'createdByUser'],
    });

    return datasets;
  }
}
