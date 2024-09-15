import { Test } from '@nestjs/testing';
import { ServerFeatureDatasetService } from './server-feature-dataset.service';

describe('ServerFeatureDatasetService', () => {
  let service: ServerFeatureDatasetService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [ServerFeatureDatasetService],
    }).compile();

    service = module.get(ServerFeatureDatasetService);
  });

  it('should be defined', () => {
    expect(service).toBeTruthy();
  });
});
