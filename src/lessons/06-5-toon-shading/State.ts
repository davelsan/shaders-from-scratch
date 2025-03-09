import { createStore } from 'jotai';

import { atomWithAssets, atomWithBinding, atomWithThree } from '@helpers/atoms';

const store = createStore();
export const state = atomWithThree('#root', store);

export const assets = atomWithAssets(store, {
  cubeTextures: {
    sunset: [
      'images/Cold_Sunset__Cam_2_Left+X.png',
      'images/Cold_Sunset__Cam_3_Right-X.png',
      'images/Cold_Sunset__Cam_4_Up+Y.png',
      'images/Cold_Sunset__Cam_5_Down-Y.png',
      'images/Cold_Sunset__Cam_0_Front+Z.png',
      'images/Cold_Sunset__Cam_1_Back-Z.png',
    ],
  },
  gltfs: {
    suzanne: 'models/suzanne.glb',
  },
});

const ambient = atomWithBinding(store, { title: 'Ambient' });
export const ambientIntensityBinding = ambient('Intensity', 0.0, {
  min: 0,
  max: 1,
  step: 0.01,
});

const hemi = atomWithBinding(store, { title: 'Hemisphere' });
export const hemiIntensityBinding = hemi('Intensity', 0.2, {
  min: 0,
  max: 1,
  step: 0.01,
});

const lambert = atomWithBinding(store, { title: 'Lambert' });
export const lambertIntensityBinding = lambert('Intensity', 0.8, {
  min: 0,
  max: 1,
  step: 0.01,
});
