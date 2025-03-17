import { createStore } from 'jotai';

import { atomWithThree } from '@helpers/atoms';

const store = createStore();
export const state = atomWithThree('#root', store);
