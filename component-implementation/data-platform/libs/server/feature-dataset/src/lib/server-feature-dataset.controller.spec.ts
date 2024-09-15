import { Test } from '@nestjs/testing';
import { ServerFeatureDatasetController } from './server-feature-dataset.controller';
import { ServerFeatureDatasetService } from './server-feature-dataset.service';

describe('ServerFeatureDatasetController', () => {
  let controller: ServerFeatureDatasetController;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [ServerFeatureDatasetService],
      controllers: [ServerFeatureDatasetController],
    }).compile();

    controller = module.get(ServerFeatureDatasetController);
  });

  it('should be defined', () => {
    expect(controller).toBeTruthy();
  });
});
