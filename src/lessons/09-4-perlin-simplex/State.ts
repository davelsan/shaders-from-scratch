import { createStore } from 'jotai';

import { atomWithBinding, atomWithThree } from '@helpers/atoms';

const store = createStore();
export const state = atomWithThree('#root', store);

const debug = atomWithBinding(store, {
  type: 'root',
  expanded: true,
});

export const withFbm = debug('FBM', true);
export const octaves = debug('octaves', 1, {
  min: 1,
  max: 8,
  step: 1,
});
