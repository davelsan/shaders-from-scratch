import { createStore } from 'jotai';

import { atomWithBinding, atomWithThree } from '@helpers/atoms';

const store = createStore();
export const state = atomWithThree('#root', store);

const debug = atomWithBinding(store, {
  type: 'root',
  expanded: true,
});

export const lighting = debug('Lighting', false);

export const noiseType = debug('FBM', 4, {
  options: {
    fbm: 0,
    ridgedFBM: 1, // mountains, steep cliffs, rocky terrain
    turbulenceFBM: 2, // turbulence
    voronoi: 3, // cellular
    stepped: 4,
    domainWarpingFBM: 5,
  },
});

export const octaves = debug('Octaves', 4, {
  min: 1,
  max: 8,
  step: 1,
});

export const useResolution = debug('Resolution', false);
