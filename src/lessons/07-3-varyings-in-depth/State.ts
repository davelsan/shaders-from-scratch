import { atomWithAssets, atomWithBinding } from '@helpers/atoms';
import { createThreeState } from '@helpers/three';

export const state = createThreeState();

export const assets = atomWithAssets(state.store, {
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

const model = atomWithBinding(state.store, { title: 'Model' });
export const modelColorBinding = model('Color', '#AAAAAA');
