import { Body, Controller, Get, Param, Post, Delete, UseGuards, Req } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiTags, ApiOperation } from '@nestjs/swagger';
import { RequireAuth } from '@salvachll/server/utils';
import { WorkspaceDto, CreateWorkspaceDto } from '@salvachll/shared/domain';
import { ServerFeatureWorkspaceService } from './server-feature-workspace.service';
import { AuthorizationService } from '@salvachll/server/auth-service';
import { Request } from 'express';

@Controller('workspace')
@ApiTags("Workspace")
@ApiBearerAuth()
export class ServerFeatureWorkspaceController {
  constructor(
    private readonly workspaceService: ServerFeatureWorkspaceService,
    private readonly authorizationService: AuthorizationService
  ) { }

  @Post('')
  @ApiOperation({ summary: 'Create a new workspace', description: 'Creates a new workspace for a user or tenant.' })
  @ApiOkResponse({
    type: WorkspaceDto, // The response will return details of the created workspace
  })
  @UseGuards(RequireAuth)
  async createWorkspace(
    @Req() request: Request,
    @Body() data: CreateWorkspaceDto
  ): Promise<WorkspaceDto> {
    const auth = request.headers.authorization ?? '';
    const authHeader = await this.authorizationService.getRequestorUser(auth);
    return await this.workspaceService.createWorkspace(data, authHeader);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get workspace details', description: 'Retrieves the details of a specific workspace.' })
  @ApiOkResponse({
    type: WorkspaceDto, // The response will return details of the workspace
  })
  @UseGuards(RequireAuth)
  async getWorkspace(@Param('id') id: string, @Req() request: Request): Promise<WorkspaceDto> {
    const auth = request.headers.authorization ?? '';
    const authHeader = await this.authorizationService.getRequestorUser(auth);
    return await this.workspaceService.getWorkspace(id, authHeader);
  }

  @Delete(':id/delete')
  @ApiOperation({ summary: 'Delete a workspace', description: 'Deletes a workspace and its associated data.' })
  @ApiOkResponse({
    description: 'The workspace has been deleted successfully.',
  })
  @UseGuards(RequireAuth)
  async deleteWorkspace(@Param('id') id: string, @Req() request: Request): Promise<void> {
    const auth = request.headers.authorization ?? '';
    const authHeader = await this.authorizationService.getRequestorUser(auth);
    return await this.workspaceService.deleteWorkspace(id, authHeader);
  }

  @Get('tenant/:tenantId')
  @ApiOperation({ summary: 'List workspaces by tenant', description: 'Lists all workspaces that belong to a specific tenant.' })
  @ApiOkResponse({
    type: [WorkspaceDto], // The response will return a list of workspaces
  })
  @UseGuards(RequireAuth)
  async listWorkspacesByTenant(@Param('tenantId') tenantId: string, @Req() request: Request): Promise<WorkspaceDto[]> {
    const auth = request.headers.authorization ?? '';
    const authHeader = await this.authorizationService.getRequestorUser(auth);
    return await this.workspaceService.listWorkspacesByTenant(tenantId, authHeader);
  }
}
