import { createStore } from 'jotai';

import { atomWithAssets, atomWithThree } from '@helpers/atoms';

const store = createStore();
export const state = atomWithThree('#root', store);

export const assets = atomWithAssets(store, {
  textures: {
    dog: 'textures/dog.jpg',
    plants: 'textures/plants.png',
  },
});
