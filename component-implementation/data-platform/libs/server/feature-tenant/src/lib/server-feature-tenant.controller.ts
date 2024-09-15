import { Body, Controller, Get, Param, Post, UseGuards, Req } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiTags, ApiOperation } from '@nestjs/swagger';
import { RequireAuth } from '@salvachll/server/utils';
import { TenantDto, CreateTenantDto, AddUserDto } from '@salvachll/shared/domain';
import { AuthorizationService } from '@salvachll/server/auth-service';
import { Request } from 'express';
import { ServerFeatureTenantService } from './server-feature-tenant.service';

@Controller('tenant')
@ApiTags("Tenant")
@ApiBearerAuth()
export class ServerFeatureTenantController {
  constructor(
    private readonly tenantService: ServerFeatureTenantService,
    private readonly authorizationService: AuthorizationService
  ) { }

  @Post('')
  @ApiOperation({ summary: 'Create a new tenant', description: 'Creates a new tenant on the platform, assigning the requestor as the owner.' })
  @ApiOkResponse({
    type: TenantDto, // The response will return details of the created tenant
  })
  @UseGuards(RequireAuth)
  async createTenant(
    @Req() request: Request,
    @Body() data: CreateTenantDto
  ): Promise<TenantDto> {
    // Create a new tenant on the platform
    const auth = request.headers.authorization ?? '';
    const authHeader = await this.authorizationService.getRequestorUser(auth);
    return await this.tenantService.createTenant(data, authHeader);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get tenant details', description: 'Retrieves details of a specific tenant including users, datasets, and workspaces.' })
  @ApiOkResponse({
    type: TenantDto, // The response will return details including users, datasets, and workspaces
  })
  @UseGuards(RequireAuth)
  async getTenant(@Param('id') id: string, @Req() request: Request): Promise<TenantDto> {
    // Retrieves tenant details including associated users, datasets, and workspaces
    const auth = request.headers.authorization ?? '';
    const authHeader = await this.authorizationService.getRequestorUser(auth);
    return await this.tenantService.getTenantDetails(id, authHeader);
  }

  @Post(':id/addUser')
  @ApiOperation({ summary: 'Add a user to a tenant', description: 'Adds a new user to a tenant, assigning them a role within the tenant.' })
  @ApiOkResponse({
    type: TenantDto, // The response will return the updated tenant object
  })
  @UseGuards(RequireAuth)
  async addUserToTenant(
    @Param('id') tenantId: string,
    @Body() userData: AddUserDto, // Assuming a userId and a role are passed in
    @Req() request: Request
  ): Promise<TenantDto> {
    // Adds a user to a tenant, assigning them a role
    const auth = request.headers.authorization ?? '';
    const authHeader = await this.authorizationService.getRequestorUser(auth);
    return await this.tenantService.addUserToTenant(tenantId, userData, authHeader);
  }

  @Get('')
  @ApiOperation({ summary: 'List all tenants', description: 'Lists all tenants where the requestor is a member.' })
  @ApiOkResponse({
    type: [TenantDto], // The response will return a list of tenants
  })
  @UseGuards(RequireAuth)
  async listTenants(@Req() request: Request): Promise<TenantDto[]> {
    // List all tenants
    const auth = request.headers.authorization ?? '';
    const authHeader = await this.authorizationService.getRequestorUser(auth);
    return await this.tenantService.listTenants(authHeader);
  }
}
