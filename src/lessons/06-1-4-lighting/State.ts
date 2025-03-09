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

/* MODEL */

const model = atomWithBinding(store, { title: 'Model' });

type ModelBindingOptions = 'suzanne' | 'sphere';
export const modelBinding = model<ModelBindingOptions>('Model', 'suzanne', {
  options: {
    Suzanne: 'suzanne',
    Sphere: 'sphere',
  },
});

export const modelColorBinding = model('Color', '#AAAAAA');

/* LIGHTING */

const ambient = atomWithBinding(store, { title: 'Ambient' });
export const ambientBinding = ambient('Enabled', true);
export const ambientIntensityBinding = ambient('Intensity', 0.0, {
  min: 0,
  max: 1,
  step: 0.01,
});

const hemi = atomWithBinding(store, { title: 'Hemisphere' });
export const hemiBinding = hemi('Enabled', true);
export const hemiIntensityBinding = hemi('Intensity', 0.2, {
  min: 0,
  max: 1,
  step: 0.01,
});

const lambert = atomWithBinding(store, { title: 'Lambert' });
export const lambertBinding = lambert('Enabled', true);
export const lambertIntensityBinding = lambert('Intensity', 0.8, {
  min: 0,
  max: 1,
  step: 0.01,
});

const specular = atomWithBinding(store, { title: 'Specular' });
export const specEnabledBinding = specular('Enabled', true);
export const specTypeBinding = specular<0 | 1>('Type', 1, {
  options: {
    Phong: 0,
    BlinnPhong: 1,
  },
});
export const specIntensityBinding = specular('Intensity', 32.0, {
  min: 8.0,
  max: 64.0,
  step: 1.0,
});

const specMap = atomWithBinding(store, { title: 'Specular Map' });
export const specMapBinding = specMap('Enabled', true);
export const specMapIntensityBinding = specMap('Intensity', 1.0, {
  min: 0.0,
  max: 1.0,
  step: 0.01,
});

const fresnel = atomWithBinding(store, { title: 'Fresnel' });
export const fresnelBinding = fresnel('Enabled', true);
export const fresnelFalloffBinding = fresnel('Falloff', 2.0, {
  min: 1.0,
  max: 6.0,
  step: 0.1,
});
