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
});

/* MODEL */

const model = atomWithBinding(store, { title: 'Model' });
export const modelColorBinding = model('Color', '#AAAAAA');
