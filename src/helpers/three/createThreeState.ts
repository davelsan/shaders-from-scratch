import { createStore as JotaiCreateStore } from 'jotai';

import { atomWithAssets, atomWithThree } from '../atoms';
import {
  CubeTextureAssets,
  DataTextureAssets,
  GLTFAssets,
  ResourceLoaderParams,
  TextureAssets,
} from './ResourceLoader';

export type State = ReturnType<typeof createThreeState>;
export type Store = ReturnType<typeof JotaiCreateStore>;

export function createThreeState<
  CubeTextures extends CubeTextureAssets,
  DataTextures extends DataTextureAssets,
  Textures extends TextureAssets,
  GLTFs extends GLTFAssets,
>(
  ...assetArgs: ResourceLoaderParams<
    CubeTextures,
    DataTextures,
    Textures,
    GLTFs
  >
) {
  const store = JotaiCreateStore();

  const assets = atomWithAssets(store, ...assetArgs);

  const [
    threeAtom, // camera, controls, renderer, scene, stage
    vpAtom, // viewport
    timeAtom, // time
  ] = atomWithThree('#root', store);

  return {
    assets,
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
