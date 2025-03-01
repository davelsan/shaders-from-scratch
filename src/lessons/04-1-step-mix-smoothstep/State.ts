import { atomWithAssets, atomWithBinding } from '@helpers/atoms';
import { createThreeState } from '@helpers/three';

import homework1Shader from './homework_1.frag.glsl';
import homework2Shader from './homework_2.frag.glsl';
import lessonShader from './shader.frag.glsl';

export const state = createThreeState();

export const assets = atomWithAssets(state.store, {
  textures: {
    plants: 'plants.png',
  },
});

const debugBinding = atomWithBinding(state.store, {
  title: 'Step, Mix, Smoothstep',
});

export const shaderAtom = debugBinding('Shader', lessonShader, {
  options: {
    lesson: lessonShader,
    homework_1: homework1Shader,
    homework_2: homework2Shader,
  },
});
