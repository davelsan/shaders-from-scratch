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

const model = atomWithBinding(state.store, { title: 'Model' });
type ModelBindingOptions = 'suzanne' | 'sphere';
export const modelBinding = model<ModelBindingOptions>('model', 'suzanne', {
  options: {
    Suzanne: 'suzanne',
    Sphere: 'sphere',
  },
});

const ambient = atomWithBinding(state.store, { title: 'Ambient' });
export const ambientBinding = ambient('Enabled', false);
export const ambientIntensityBinding = ambient('Intensity', 1.0, {
  min: 0,
  max: 1,
  step: 0.01,
});

const hemi = atomWithBinding(state.store, { title: 'Hemisphere' });
export const hemiBinding = hemi('Enabled', false);
export const hemiIntensityBinding = hemi('Intensity', 1.0, {
  min: 0,
  max: 1,
  step: 0.01,
});

const lambert = atomWithBinding(state.store, { title: 'Lambert' });
export const lambertBinding = lambert('Enabled', true);
export const lambertIntensityBinding = lambert('Intensity', 1.0, {
  min: 0,
  max: 1,
  step: 0.01,
});

const specular = atomWithBinding(state.store, { title: 'Specular' });
export const specPhongBinding = specular('Enabled', true);
export const specPhongIntensityBinding = specular('Intensity', 32.0, {
  min: 8.0,
  max: 64.0,
  step: 1.0,
});

const specMap = atomWithBinding(state.store, { title: 'Specular Map' });
export const specMapBinding = specMap('Enabled', true);
export const specMapIntensityBinding = specMap('Intensity', 1.0, {
  min: 0.0,
  max: 1.0,
  step: 0.01,
});

const fresnel = atomWithBinding(state.store, { title: 'Fresnel' });
export const fresnelBinding = fresnel('Enabled', true);
export const fresnelFalloffBinding = fresnel('Falloff', 2.0, {
  min: 1.0,
  max: 6.0,
  step: 0.1,
});
