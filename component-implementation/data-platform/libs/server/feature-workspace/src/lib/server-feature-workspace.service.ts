import { Injectable, NotFoundException, ForbiddenException, ConflictException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { WorkspaceEntitySchema, TenantEntitySchema, UserEntitySchema, TenantUserEntitySchema } from '@salvachll/server/data-access';
import { Repository } from 'typeorm';
import { WorkspaceDto, CreateWorkspaceDto, AuthorizationHeader } from '@salvachll/shared/domain';
import { CMCService } from '@salvachll/server/cmc-service';

@Injectable()
export class ServerFeatureWorkspaceService {
  private readonly logger = new Logger(ServerFeatureWorkspaceService.name);

  constructor(
    @InjectRepository(WorkspaceEntitySchema)
    private workspaceRepository: Repository<WorkspaceEntitySchema>,
    @InjectRepository(TenantEntitySchema)
    private tenantRepository: Repository<TenantEntitySchema>,
    @InjectRepository(UserEntitySchema)
    private userRepository: Repository<UserEntitySchema>,
    @InjectRepository(TenantUserEntitySchema)
    private tenantUserRepository: Repository<TenantUserEntitySchema>,
    private cmcService: CMCService,
  ) { }

  // Method to ensure the user is a member of the tenant that owns the workspace
  private async ensureUserIsTenantMember(userId: string, tenantId: string): Promise<void> {
    const tenantUser = await this.tenantUserRepository.findOne({
      where: { user: { id: userId }, tenant: { id: tenantId } },
    });

    if (!tenantUser) {
      throw new ForbiddenException('You are not authorized to perform this action.');
    }
  }

  // Create a new workspace
  async createWorkspace(data: CreateWorkspaceDto, auth: AuthorizationHeader): Promise<WorkspaceDto> {
    const userId = auth.federated_claims.user_id;
    const tenant = await this.tenantRepository.findOne({ where: { id: data.tenantId } });
    const user = await this.userRepository.findOne({ where: { id: userId } });

    if (!tenant) {
      throw new NotFoundException(`Tenant with ID '${data.tenantId}' not found.`);
    }
    if (!user) {
      throw new NotFoundException(`User with ID '${userId}' not found.`);
    }

    // Ensure the requestor is a member of the tenant
    await this.ensureUserIsTenantMember(userId, data.tenantId);

    // Check if a workspace with the same name already exists
    const existingWorkspace = await this.workspaceRepository.findOne({
      where: { id: data.id },
    });
    if (existingWorkspace) {
      throw new ConflictException(`Workspace with name '${data.id}' already exists for this tenant.`);
    }

    const workspace = this.workspaceRepository.create({
      id: data.id,
      tenant,
      createdByUser: user,
    });

    try {
      await this.cmcService.deployWorkspace({
        allowedUsers: [`${auth.federated_claims.connector_id}_${userId}`],
        creatorUser: userId,
        tenant: tenant.id,
        workspaceId: data.id
      });
    } catch (error: any) {
      this.logger.error('Error deploying workspace:', error);
      // Handle the error gracefully and return meaningful feedback to the caller
      throw new BadRequestException(`Error deploying workspace: ${JSON.stringify(error)}`);
    }

    await this.workspaceRepository.save(workspace);
    return workspace;
  }

  // Retrieve workspace details
  async getWorkspace(id: string, auth: AuthorizationHeader): Promise<WorkspaceDto> {
    const workspace = await this.workspaceRepository.findOne({
      where: { id },
      relations: ['tenant', 'createdByUser'],
    });
    const userId = auth.federated_claims.user_id;

    if (!workspace) {
      throw new NotFoundException(`Workspace with ID '${id}' not found.`);
    }

    // Ensure the requestor is a member of the tenant
    await this.ensureUserIsTenantMember(userId, workspace.tenant.id);

    return workspace;
  }

  // Delete a workspace
  async deleteWorkspace(id: string, auth: AuthorizationHeader): Promise<void> {
    const workspace = await this.getWorkspace(id, auth);
    const userId = auth.federated_claims.user_id;

    // Ensure the requestor is a member of the tenant
    await this.ensureUserIsTenantMember(userId, workspace.tenantId);

    await this.workspaceRepository.remove(workspace as WorkspaceEntitySchema);
  }

  // Method to list workspaces by tenant
  async listWorkspacesByTenant(tenantId: string, auth: AuthorizationHeader): Promise<WorkspaceDto[]> {
    const userId = auth.federated_claims.user_id;

    // Ensure the requestor is a member of the tenant
    await this.ensureUserIsTenantMember(userId, tenantId);

    // Fetch all workspaces for the specified tenant
    const workspaces = await this.workspaceRepository.find({
      where: { tenant: { id: tenantId } },
      loadEagerRelations: true
    });

    return workspaces;
  }
}
