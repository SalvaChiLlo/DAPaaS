import * as S from '@effect/schema/Schema';
import { BaseDto } from './base.dto';

export const MetadataDto = S.Record(S.String, S.String); // Example structure for metadata, can be more complex if needed

export const DatasetDto = S.Struct({
  ...BaseDto.fields, // Common fields like createdAt, updatedAt, deletedAt
  tenantId: S.String, // The tenant that owns the dataset (foreign key reference to Tenant)
  createdByUserId: S.String, // The user who created the dataset (foreign key reference to User)
  datasetName: S.String.pipe(S.minLength(1), S.maxLength(50)), // Name of the dataset
  metadata: MetadataDto, // Metadata stored in a structured format
});

export type DatasetDto = S.Schema.Type<typeof DatasetDto>;

export const CreateDatasetDto = DatasetDto.pick("datasetName", "tenantId", "metadata");
export type CreateDatasetDto = S.Schema.Type<typeof CreateDatasetDto>;

export const UpdateDatasetDto = S.partial(CreateDatasetDto);
export type UpdateDatasetDto = S.Schema.Type<typeof UpdateDatasetDto>;
