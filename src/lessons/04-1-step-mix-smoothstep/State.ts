import { createStore } from 'jotai';

import { atomWithAssets, atomWithBinding, atomWithThree } from '@helpers/atoms';

import homework1Shader from './homework_1.frag.glsl';
import homework2Shader from './homework_2.frag.glsl';
import lessonShader from './shader.frag.glsl';

const store = createStore();
export const state = atomWithThree('#root', store);

export const assets = atomWithAssets(store, {
  textures: {
    plants: 'plants.png',
  },
});

const debugBinding = atomWithBinding(store, {
  title: 'Step, Mix, Smoothstep',
});

export const shaderAtom = debugBinding('Shader', lessonShader, {
  options: {
    lesson: lessonShader,
    homework_1: homework1Shader,
    homework_2: homework2Shader,
  },
});
