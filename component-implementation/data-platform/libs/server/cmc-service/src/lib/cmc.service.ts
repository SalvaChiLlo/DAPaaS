import { Injectable, OnModuleInit, Logger, BadRequestException } from '@nestjs/common';
import { AuthorizationHeader, UserDto } from '@salvachll/shared/domain';
import { InjectRepository } from '@nestjs/typeorm';
import { UserEntitySchema } from '@salvachll/server/data-access';
import { Repository } from 'typeorm';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs'; // To convert Observable to Promise
import { AxiosError, AxiosResponse } from 'axios';
import * as jwt from 'jsonwebtoken';
import * as https from 'https'; // Import https module to create an HTTPS agent

@Injectable()
export class CMCService {
  private readonly logger = new Logger(CMCService.name);

  cmcUrl = process.env?.['CMC_URL'] ?? '';
  baseUrl = process.env?.['BASE_URL'] ?? '';

  constructor(
    @InjectRepository(UserEntitySchema)
    private userRepository: Repository<UserDto>,
    private httpService: HttpService // Inject HttpService to perform HTTP calls
  ) {

    if (!this.cmcUrl) {
      this.logger.error("CMC_URL not set");
      throw new Error("CMC_URL is required");
    }
    if (!this.baseUrl) {
      this.logger.error("BASE_URL not set");
      throw new Error("BASE_URL is required");
    }
  }

  async deployWorkspace(options: { tenant: string, creatorUser: string, allowedUsers: string[], workspaceId: string }) {
    try {
      const { tenant, creatorUser, allowedUsers, workspaceId, } = options
      // Create Account
      const workspaceInfo = {
        deployment: {
          name: "dapaas-platform",
          up: null,
          meta: {
            workspaceId: `workspace/${workspaceId}`
          },
          config: {
            parameter: {
              common: {
                defaultUser: "admin",
                imageRegistry: "docker.io",
                dbNames: ["dapaas", "airflow"],
                baseUrl: this.baseUrl, // "https://dapaas.vera.kumori.cloud",
                workspaceUrlPrefix: `workspace/${workspaceId}`,
                jwksUrl: `${this.baseUrl}/idp/keys`,
                tenant,
                creatorUser
              },
              minio: {},
              postgres: {},
              grafana: {},
              airflow: {},
              vscode: {},
              workspace_manager: {},
              access_gateway: { allowedUsers: allowedUsers.join(",") },
              fsync: {}
            },
            resource: {
              imageRegistrySecret: { secret: "cluster.core/docker_hub_demo" },
              defaultPassword: { secret: "dapaas_default_password" },
              publicKey: { secret: "dapaas_publickey" },
              privateKey: { secret: "dapaas_privatekey" },
              minio_vol: { volume: { kind: "storage", size: 1, unit: "G" } },
              postgres_vol: { volume: { kind: "storage", size: 1, unit: "G" } },
              grafana_vol: { volume: { kind: "storage", size: 1, unit: "G" } },
              vscode_vol: { volume: { kind: "storage", size: 1, unit: "G" } },
              fsync_vol: { volume: { kind: "storage", size: 1, unit: "G" } }
            },
            resilience: 0,
            scale: {
              detail: {
                minio: { hsize: 1 },
                postgres: { hsize: 1 },
                grafana: { hsize: 1 },
                airflow: { hsize: 1 },
                vscode: { hsize: 1 },
                workspace_manager: { hsize: 1 },
                access_gateway: { hsize: 1 },
                fsync: { hsize: 1 }
              }
            }
          },
          artifact: {
            spec: [1, 0],
            ref: {
              version: [0, 0, 7],
              name: "",
              kind: "service",
              domain: "salvachillo.dapaas",
              module: "user_workspace_service"
            }
          }
        },
        comment: "",
        meta: {
          workspaceId: `workspace/${workspaceId}`
        }
      }
      this.logger.debug(JSON.stringify(workspaceInfo))
      await this.makeRequest(`tenant/dapaas/service/${workspaceId}/simple`, workspaceInfo);

      // Repeat this request until succeeds
      await this.retryMakeRequest(`tenant/dapaas/service/dapaas/client/workspace/tenant/dapaas/service/${workspaceId}/server/access_gateway`, {});

    } catch (error: any) {
      this.logger.error('Error during workspace creation:', JSON.stringify((error as AxiosError).response?.data));
      throw new BadRequestException('Workspace creation failed', JSON.stringify((error as AxiosError).response?.data));
    }
  }

  // Helper function to make HTTP requests and handle status codes 200 or 409
  private async makeRequest(endpoint: string, data?: any): Promise<void> {
    try {
      // Create an https.Agent with client certificates
      const httpsAgent = new https.Agent({
        cert: process.env?.['ABW_CLUSTER_CERT'] || '',
        key: process.env?.['ABW_CLUSTER_KEY'] || '',
        ca: process.env?.['ABW_CLUSTER_CA'] || '',
        rejectUnauthorized: false
      });

      const response = data ? await lastValueFrom(
        this.httpService.post(`${this.cmcUrl}/${endpoint}`, data, {
          httpsAgent,
        })
      ) : await lastValueFrom(
        this.httpService.get(`${this.cmcUrl}/${endpoint}`, {
          httpsAgent,
        })
      )

      this.handleHttpResponse(response);
    } catch (error: any) {
      if (error.response?.status === 409) {
        this.logger.warn(`Conflict detected (409) at ${endpoint}, proceeding.`);
      } else {
        throw error; // Re-throw the error for any other status
      }
    }
  }

  private async retryMakeRequest(endpoint: string, data: any): Promise<void> {
    const MAX_RETRIES = 100;
    const RETRY_DELAY_MS = 5000; // 5 seconds delay between retries
    let attempt = 0;

    while (attempt < MAX_RETRIES) {
      try {
        // Attempt to make the request
        await this.makeRequest(endpoint, data);
        return; // If successful, exit the loop
      } catch (error: any) {
        attempt++;
        if (attempt >= MAX_RETRIES) {
          this.logger.error(`Max retries reached for ${endpoint}.`);
          throw error; // Re-throw the error if max retries are reached
        }

        this.logger.warn(`Retry ${attempt}/${MAX_RETRIES} failed for ${endpoint}. Retrying in ${RETRY_DELAY_MS / 1000} seconds...`);
        await this.delay(RETRY_DELAY_MS); // Wait before retrying
      }
    }
  }

  // Delay function
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Handle HTTP Response
  private handleHttpResponse(response: AxiosResponse<any>) {
    if (response.status === 200 || response.status === 409) {
      this.logger.log(`HTTP Response Status: ${response.status}`);
      this.logger.log(`HTTP Response Data: ${JSON.stringify(response.data)}`);
    } else {
      throw new Error(`Unexpected HTTP status code: ${response.status}`);
    }
  }
}

// JWT generation function
export function generateHeaders(payload: AuthorizationHeader): { Authorization: string } {
  const secretKey = process.env['JWT_SECRET'] || 'your-secret-key'; // Make sure you set a strong secret key in your environment variables

  // Sign the payload to generate the JWT
  const token = jwt.sign(payload, secretKey, {
    algorithm: 'HS256', // You can choose a different algorithm if needed
  });

  // Return the Authorization header with the Bearer token
  return {
    Authorization: `Bearer ${token}`,
  };
}
