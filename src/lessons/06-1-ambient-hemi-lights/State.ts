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
  gltfs: {
    suzanne: 'models/suzanne.glb',
  },
});

const debug = atomWithBinding(state.store, {
  title: 'Lighting',
});

export const ambientBinding = debug('Ambient', true);
export const ambientIntensityBinding = debug('Ambient Intensity', 1.0, {
  min: 0,
  max: 1,
  step: 0.01,
});

export const hemiBinding = debug('Hemisphere', true);
export const hemiIntensityBinding = debug('Hemisphere Intensity', 1.0, {
  min: 0,
  max: 1,
  step: 0.01,
});

export const lambertBinding = debug('Lambert', true);
export const lambertIntensityBinding = debug('Lambert Intensity', 1.0, {
  min: 0,
  max: 1,
  step: 0.01,
});
