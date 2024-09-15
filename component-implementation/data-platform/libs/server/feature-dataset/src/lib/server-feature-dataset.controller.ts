import { Body, Controller, Get, Param, Post, Patch, UseGuards, Req } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiTags, ApiOperation } from '@nestjs/swagger';
import { RequireAuth } from '@salvachll/server/utils';
import { DatasetDto, CreateDatasetDto, UpdateDatasetDto } from '@salvachll/shared/domain';
import { ServerFeatureDatasetService } from './server-feature-dataset.service';
import { AuthorizationService } from '@salvachll/server/auth-service';
import { Request } from 'express';

@Controller('dataset')
@ApiTags("Dataset")
@ApiBearerAuth()
export class ServerFeatureDatasetController {
  constructor(
    private readonly datasetService: ServerFeatureDatasetService,
    private readonly authorizationService: AuthorizationService
  ) { }

  @Post('')
  @ApiOperation({ summary: 'Create a new dataset', description: 'Creates a new dataset under a tenant with metadata.' })
  @ApiOkResponse({
    type: DatasetDto, // The response will return details of the created dataset
  })
  @UseGuards(RequireAuth)
  async createDataset(
    @Req() request: Request,
    @Body() data: CreateDatasetDto
  ): Promise<DatasetDto> {
    const auth = request.headers.authorization ?? '';
    const authHeader = await this.authorizationService.getRequestorUser(auth);
    return await this.datasetService.createDataset(data, authHeader);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get dataset details', description: 'Retrieves the details of a specific dataset using its ID.' })
  @ApiOkResponse({
    type: DatasetDto, // The response will return details of the dataset
  })
  @UseGuards(RequireAuth)
  async getDataset(@Param('id') id: string, @Req() request: Request): Promise<DatasetDto> {
    const auth = request.headers.authorization ?? '';
    const authHeader = await this.authorizationService.getRequestorUser(auth);
    return await this.datasetService.getDataset(id, authHeader);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update dataset', description: 'Updates the details of a dataset such as name and metadata.' })
  @ApiOkResponse({
    type: DatasetDto, // The response will return updated details of the dataset
  })
  @UseGuards(RequireAuth)
  async updateDataset(
    @Param('id') id: string,
    @Body() data: UpdateDatasetDto,
    @Req() request: Request
  ): Promise<DatasetDto> {
    const auth = request.headers.authorization ?? '';
    const authHeader = await this.authorizationService.getRequestorUser(auth);
    return await this.datasetService.updateDataset(id, data, authHeader);
  }

  @Get('tenant/:tenantId')
  @ApiOperation({ summary: 'List datasets by tenant', description: 'Lists all datasets that belong to a specific tenant.' })
  @ApiOkResponse({
    type: [DatasetDto], // The response will return a list of datasets
  })
  @UseGuards(RequireAuth)
  async listDatasetsByTenant(
    @Param('tenantId') tenantId: string,
    @Req() request: Request
  ): Promise<DatasetDto[]> {
    const auth = request.headers.authorization ?? '';
    const authHeader = await this.authorizationService.getRequestorUser(auth);
    return await this.datasetService.listDatasetsByTenant(tenantId, authHeader);
  }
}
