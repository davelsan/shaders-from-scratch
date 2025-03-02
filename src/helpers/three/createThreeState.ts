import { createStore as JotaiCreateStore } from 'jotai';

import { atomWithThree } from '../atoms';

export type State = ReturnType<typeof createThreeState>;
export type Store = ReturnType<typeof JotaiCreateStore>;

export function createThreeState() {
  const store = JotaiCreateStore();

  const [
    threeAtom, // camera, controls, renderer, scene, stage
    vpAtom, // viewport
    timeAtom, // time
  ] = atomWithThree('#root', store);

  return {
    store,
    threeAtom,
    timeAtom,
    vpAtom,
    //
    get three() {
      return store.get(threeAtom);
    },
    get vp() {
      return store.get(vpAtom);
    },
    get time() {
      return store.get(timeAtom);
    },
  };
}
