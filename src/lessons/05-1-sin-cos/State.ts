import { atomWithAssets } from '@helpers/atoms';
import { createThreeState } from '@helpers/three';

export const state = createThreeState();

export const assets = atomWithAssets(state.store, {
  textures: {
    dog: 'dog.jpg',
  },
});
