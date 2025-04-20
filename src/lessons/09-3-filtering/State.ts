import { createStore } from 'jotai';

import { atomWithAssets, atomWithBinding, atomWithThree } from '@helpers/atoms';

const store = createStore();
export const state = atomWithThree('#root', store);

export const assets = atomWithAssets(store, {
  textures: {
    colors: 'textures/colors.png',
  },
});

export enum FilterType {
  LINEAR,
  SMOOTH,
}

export enum TargetType {
  NOISE,
  TEXTURE,
}

const debug = atomWithBinding(store, {
  type: 'root',
  expanded: true,
});

export const filterType = debug('Filter', FilterType.SMOOTH, {
  options: {
    linear: FilterType.LINEAR,
    smooth: FilterType.SMOOTH,
  },
});

export const targetType = debug('Target', TargetType.NOISE, {
  options: {
    noise: TargetType.NOISE,
    texture: TargetType.TEXTURE,
  },
});
