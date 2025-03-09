import { createStore } from 'jotai';

import { atomWithBinding, atomWithThree } from '@helpers/atoms';

const store = createStore();
export const state = atomWithThree('#root', store);

const debug = atomWithBinding(store, {
  title: 'Debug',
});

export const fnBinding = debug('Function', 0, {
  options: {
    abs: 0,
    floor: 1,
    ceil: 2,
    round: 3,
    fract: 4,
    mod: 5,
  },
});

export const modFnValueBinding = debug('modFnValue', 1.0, {
  min: 0.5,
  max: 2.0,
});
