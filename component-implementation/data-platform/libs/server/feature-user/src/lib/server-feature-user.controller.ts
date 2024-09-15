import { Body, Controller, Get, Param, Post, UseGuards, Req } from '@nestjs/common';
import { ServerFeatureUserService } from './server-feature-user.service';
import { CreateUserDto, UserDto } from '@salvachll/shared/domain';
import { ApiBearerAuth, ApiOkResponse, ApiTags, ApiOperation } from '@nestjs/swagger';
import { RequireAuth } from '@salvachll/server/utils';
import * as S from '@effect/schema/Schema';
import { AuthorizationService } from '@salvachll/server/auth-service';
import { Request } from 'express';

@Controller('user')
@ApiTags("User")
@ApiBearerAuth()
export class ServerFeatureUserController {
  constructor(
    private ServerFeatureUserService: ServerFeatureUserService,
    private readonly authorizationService: AuthorizationService
  ) { }

  @Post('')
  @ApiOperation({ summary: 'Register a new user', description: 'Registers a new user with the platform.' })
  @ApiOkResponse({
    type: UserDto // Assuming the response will return details after registration
  })
  @UseGuards(RequireAuth)
  async create(@Req() request: Request): Promise<UserDto> {
    // Registers a new user with the platform
    const auth = request.headers.authorization ?? ""
    const authHeader = await this.authorizationService.getRequestorUser(auth, false)
    return await this.ServerFeatureUserService.createUser(authHeader);
  }

  @Get('')
  @ApiOperation({ summary: 'List all users', description: 'Lists all users in the platform.' })
  @ApiOkResponse({
    type: S.Array(UserDto) // Assuming the response will return an array of user details
  })
  @UseGuards(RequireAuth)
  async list(@Req() request: Request): Promise<UserDto[]> {
    // Lists all users in the platform
    const auth = request.headers.authorization ?? ""
    const authHeader = await this.authorizationService.getRequestorUser(auth)
    return await this.ServerFeatureUserService.listUsers(authHeader);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user details', description: 'Retrieves details of a specific user including associated tenants, workspaces, and roles.' })
  @ApiOkResponse({
    type: UserDto // Assuming this returns details including tenants, workspaces, and roles
  })
  @UseGuards(RequireAuth)
  async getOne(@Param('id') id: string, @Req() request: Request): Promise<UserDto> {
    // Retrieves user details including associated tenants, workspaces, and roles
    const auth = request.headers.authorization ?? ""
    const authHeader = await this.authorizationService.getRequestorUser(auth)
    if (id === "info")
      return await this.ServerFeatureUserService.getUserDetails(authHeader.federated_claims.user_id, authHeader);
    return await this.ServerFeatureUserService.getUserDetails(id, authHeader);
  }
}
