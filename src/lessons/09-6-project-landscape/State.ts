import { createStore } from 'jotai';

import { atomWithBinding, atomWithThree } from '@helpers/atoms';

const store = createStore();
export const state = atomWithThree('#root', store);

const blur = atomWithBinding(store, {
  title: 'Blur',
  expanded: true,
});

export const backgroundBlur = blur('Background', 6000.0, {
  min: 3000,
  max: 8000,
});

export const foregroundBlur = blur('Foreground', -1400, {
  min: -4000,
  max: -1000,
});
