import { ConflictException, Injectable, InternalServerErrorException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { TenantDto, CreateTenantDto, UpdateTenantDto, AuthorizationHeader, UserDto, UserRoles } from '@salvachll/shared/domain';
import { Repository } from 'typeorm';
import * as _ from 'lodash';
import { Either } from 'effect';
import { ArrayFormatter } from '@effect/schema';
import * as S from '@effect/schema/Schema';
import { TenantEntitySchema, UserEntitySchema, TenantUserEntitySchema } from '@salvachll/server/data-access';

@Injectable()
export class ServerFeatureTenantService {
  constructor(
    @InjectRepository(TenantEntitySchema)
    private tenantRepository: Repository<TenantEntitySchema>,
    @InjectRepository(UserEntitySchema)
    private userRepository: Repository<UserEntitySchema>,
    @InjectRepository(TenantUserEntitySchema)
    private tenantUserRepository: Repository<TenantUserEntitySchema>
  ) { }

  // Method to check if the requestor is an owner of the tenant
  private async ensureIsOwner(tenantId: string, requestorId: string): Promise<void> {
    const tenantUser = await this.tenantUserRepository.findOne({
      where: { tenant: { id: tenantId }, user: { id: requestorId }, role: 'owner' },
    });

    if (!tenantUser) {
      throw new ForbiddenException('You are not authorized to perform this action. Only owners can modify the tenant.');
    }
  }

  // Method to create a new tenant
  async createTenant(data: CreateTenantDto, auth: AuthorizationHeader): Promise<TenantDto> {
    const tenantName = data.id;
    const ownerId = auth.federated_claims.user_id;

    // Check if a tenant with the same name already exists
    const existingTenant = await this.tenantRepository.findOne({ where: { id: tenantName } });
    if (existingTenant) {
      throw new ConflictException(`Tenant with name '${tenantName}' already exists.`);
    }

    // Fetch the owner details (assuming the owner is the requestor)
    const owner = await this.userRepository.findOne({ where: { id: ownerId }, loadEagerRelations: true});
    if (!owner) {
      throw new NotFoundException(`Owner with ID '${ownerId}' not found.`);
    }

    // Create the tenant
    const tenant = this.tenantRepository.create({
      id: tenantName,
      datasets: [],
      workspaces: []
    });
    await this.tenantRepository.save(tenant);

    // Add the owner to the tenant with the role 'owner'
    const tenantUser = this.tenantUserRepository.create({
      tenant: tenant,
      user: owner,
      role: 'owner',
    });
    await this.tenantUserRepository.save(tenantUser);

    return this.getTenantDetails(tenant.id, auth);
  }

  // Method to get details of a specific tenant
  async getTenantDetails(tenantId: string, auth: AuthorizationHeader): Promise<TenantDto> {
    const tenant = await this.tenantRepository.findOne({
      where: { id: tenantId },
      relations: ['users', 'users.user'], // Load related users with user details
    });

    if (!tenant) {
      throw new NotFoundException(`Tenant '${tenantId}' not found.`);
    }

    const validate = S.validateEither(TenantDto)(tenant);
    if (Either.isLeft(validate)) {
      const error = ArrayFormatter.formatErrorSync(validate.left);
      console.error("Decoding failed:", error);
      throw new InternalServerErrorException(error);
    }

    return validate.right;
  }

  // Method to add a user to a tenant (requires requestor to be an owner)
  async addUserToTenant(tenantId: string, userData: { userId: string; role: UserRoles }, auth: AuthorizationHeader): Promise<TenantDto> {
    const requestorId = auth.federated_claims.user_id;

    // Check if the requestor is an owner
    await this.ensureIsOwner(tenantId, requestorId);

    const tenant = await this.getTenantDetails(tenantId, auth);

    // Check if the user already exists
    const user = await this.userRepository.findOne({ where: { id: userData.userId } });
    if (!user) {
      throw new NotFoundException(`User with ID '${userData.userId}' not found.`);
    }

    // Check if the user is already associated with the tenant
    if (tenant.users?.some((tenantUser) => tenantUser.user.id === userData.userId)) {
      throw new ConflictException(`User '${userData.userId}' is already part of the tenant.`);
    }

    // Add the user to the tenant with the specified role
    const tenantUser = this.tenantUserRepository.create({
      tenant: { id: tenantId } as TenantEntitySchema,  // Reference only by ID
      user: { id: userData.userId } as UserEntitySchema,  // Reference only by ID
      role: userData.role,
    });
    await this.tenantUserRepository.save(tenantUser);

    return this.getTenantDetails(tenantId, auth);
  }

  // Method to list all tenants where the requestor is a member
  async listTenants(auth: AuthorizationHeader): Promise<TenantDto[]> {
    const requestorId = auth.federated_claims.user_id;

    // Query the TenantUserEntitySchema to find all tenants where the requestor is a member
    const tenantUsers = await this.tenantUserRepository.find({
      where: { user: { id: requestorId } }, // Filter by requestor ID
      relations: ['tenant', 'tenant.users', 'tenant.users.user'], // Load tenant details and users
    });

    // Map through the tenantUser entities to extract the tenant information
    const tenants = tenantUsers.map(tenantUser => tenantUser.tenant);

    // Validate and return the list of tenants
    return tenants.map(tenant => {
      const validate = S.validateEither(TenantDto)(tenant);
      if (Either.isLeft(validate)) {
        const error = ArrayFormatter.formatErrorSync(validate.left);
        console.error("Decoding failed:", error);
      }
      return tenant;
    });
  }

  // Method to update an existing tenant (requires requestor to be an owner)
  async updateTenant(id: string, data: UpdateTenantDto, auth: AuthorizationHeader): Promise<TenantDto> {
    const requestorId = auth.federated_claims.user_id;

    // Check if the requestor is an owner
    await this.ensureIsOwner(id, requestorId);

    const tenant = await this.getTenantDetails(id, auth);
    const updatedTenant = _.merge(tenant, data);
    await this.tenantRepository.save(updatedTenant as TenantEntitySchema);
    return this.getTenantDetails(id, auth);
  }

  // Method to delete a tenant (requires requestor to be an owner)
  async deleteTenant(id: string, auth: AuthorizationHeader): Promise<void> {
    const requestorId = auth.federated_claims.user_id;

    // Check if the requestor is an owner
    await this.ensureIsOwner(id, requestorId);

    const tenant = await this.getTenantDetails(id, auth);
    await this.tenantRepository.remove(tenant as TenantEntitySchema);
  }
}
